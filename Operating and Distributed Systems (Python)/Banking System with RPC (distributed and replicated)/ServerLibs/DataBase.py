#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 	Instituto Superior Técnico 2010/2011
#    Operating and Distributed Systems
#
#   Code written by:
#		Filipe Funenga filipe.funenga@ist.utl.pt (57977)
#		Martim Camacho martim.camacho@ist.utl.pt (56755)
#		Pedro Silva    pedro.silva@ist.utl.pt    (58035)
#	
#	Credits:
#		 Pyro is written and © by Irmen de Jong
#		 View the software license at: http://www.xs4all.nl/~irmen/pyro3/manual/LICENSE


"""
This module includes classes and methods for the management and updating of the database. Several aspects were taken into account such as concurrent use by multiple threads using the block and other critical areas.

A database server has associated with it two objects: one is responsible for lock management in critical areas and the other by the deposit of the amount of interest in each account.
For the second part of the project is assumed that the database can be replicated across multiple machines and only one of them has these objects in execution.
"""


from time import time, ctime
from threading import Thread, Event, Lock
from os import remove,path,mkdir
import Pyro.util

class DataBaseBank:
	"""
	This class implements the database that exists on each bank server. This allows storing information of bank accounts such as the start date and balance.
	
	The two main operations to be held in each account is the debit and credit of an amount that is commanded by terminals such as ATMs, the website of the bank, etc.
	In addition to creating, it is also possible for banks to upgrade the existing accounts on their servers by applying a periodic rate of interest.
	
	In the next paragraphs will be explained in detail every method implemented.
	"""
	writelock = Lock()
	threshold = 99
	
	def __init__( self, name ):
		self.__accounts = {}
		self.__accountsLock = AccountsLock()
		self.__interestRate = InterestRateManager( self.__accounts, self.DepositInterest )
		self.log = Pyro.util.SystemLogger()
		self.vars = {'LogNum':0,
					 'OpNum':0,
					 'TranNum':0,
					 'Name':name,
					 'ConfPath':'./ServerLibs/.conf/'+name,
					 'LogPath':'./ServerLibs/.log/'+name}
		try:
			self.__readlogdata()
		except:
			pass
		if not path.exists('./ServerLibs/.conf/'):
			mkdir('./ServerLibs/.conf/')
		if not path.exists('./ServerLibs/.log/'):
			mkdir('./ServerLibs/.log/')
		if not path.exists('./ServerLibs/.conf/'+name):
			mkdir('./ServerLibs/.conf/'+name)
		if not path.exists('./ServerLibs/.log/'+name):
			mkdir('./ServerLibs/.log/'+name)
		
		Pyro.config.PYRO_LOGFILE = self.vars['LogPath'] + str(self.vars['LogNum']) + '.log'
		#self.__NewLog()
		
	def __NewLog(self):
		self.vars['OpNum']=0
		self.vars['LogNum']+=1
		Pyro.config.PYRO_LOGFILE = self.vars['LogPath'] + str(self.vars['LogNum']) + '.log'
		
		print 'LOGNUM:',self.vars['LogNum']
		print 'Starting log: ',self.vars['LogNum']

	def __readlogdata(self):
		file = open(self.vars['ConfPath']+'var.data',"r")
		for line in file:
			
			tmp = line.split(':')
			tmp[1]=tmp[1].strip('\n')
			if tmp[0] == 'LogNum':
				self.vars['LogNum']=int(tmp[1])
			elif tmp[0] == 'OpNum':
				self.vars['OpNum']=int(tmp[1])
			elif tmp[0] == 'TranNum':
				self.vars['TranNum']=int(tmp[1])
		file.close

	def __writelogdata(self):
		file = open(self.vars['ConfPath']+'var.data',"w")
		file.write('LogNum:'+str(self.vars['LogNum'])+'\n')
		file.write('OpNum:'+str(self.vars['OpNum'])+'\n')
		file.write('TranNum:'+str(self.vars['TranNum'])+'\n')
		file.close
	
	def Initialize( self, initFile=[] ):
		"""
		Creates the accounts in the database
		"""
		lineCounter = 1
		for line in initFile:
			try:
				Aid = self.NewAccount( str(line[1]), line[0] )
			except KeyError, error:
				return error+' @Line'+str(lineCounter)
			except ValueError,error:
				return error+' @Line'+str(lineCounter)
			print 'Created account ' + str(line[0]) + ' with ' + str(line[1]) + '€'
			lineCounter += 1

	def close( self ):
		"""
		Close()
		This method is used to properly close the database in compliance with all its dependencies.
		"""
		print 'The DataBase is closing..'
		self.log.raw('$$\tShutdown\n')
		self.__writelogdata()
		self.__interestRate.close()
		self.__accountsLock.close()

	def GetAccountsLock( self ):
		"""
		GetAccountsLock() -> The instance of the class responsible for controlling concurrent accesses to the accounts of the database.
		"""
		return self.__accountsLock

	def GetInterestRate( self ):
		"""
		GetInterestRate() -> The instance of the class responsible for controlling the periodically deposit of interest amounts.
		"""
		return self.__interestRate

	def __GetFirstEmptyId( self, d ):
		#TODO: Optimize this algorithm if needed.
		dID = 0
		while d.get(str(dID),None) is not None:
			dID += 1
		return dID

	def GetAccount( self, Aid ):
		"""
		GetAcount( Aid ) -> The acount's entry existing in the database as a dictionary with the following keys: 'Aamount', 'AdateOfBegin'.
		"""
		account = self.__accounts.get( str(Aid), None )
		if account is None:
			raise KeyError('Can\'t get acount. The provided Aid is not valid.')
		return account

	def GetAccountIDs( self ):
		"""
		GetAcountIDs() -> List of acounts IDs.
		"""
		keys = []
		for key in self.__accounts.iterkeys():
			keys.append(int(key))
		return keys

	def NewAccount( self, amount=0.00, newAid=None ):
		"""
		NewAccount( amount=0.00, newAid=None ) -> The Aid assigned to the new account.
		Create a new account in the database with the following optional parameters: an opening amount and an Aid to be allocated.
		It is assumed that, if given, the latter is not in use, otherwise an exception is raised.
		"""
		if amount<0:
			raise ValueError('Can\'t create new acount. The opening amount is negative.')
		if newAid is not None:
			if self.__accounts.get(str(newAid),None) is not None:
				raise KeyError('Can\'t create new acount. The acount ID is already in use.')
		else:
			newAid = self.__GetFirstEmptyId( self.__accounts )

		
		self.__accounts[ str(newAid) ] = {	'Aamount':float(amount),
											'AdateOfBegin':time(),
											'Version':0,
											'State':'Init',
											'Event':Event()}

		self.__accountsLock.NewAccount( newAid )
		
		return newAid
		
	def Deposit( self, Aid, amount ):
		"""
		Deposit(  Aid, amount )
		Deposit a specified amount to an account designated. Both variables are given as parameter.
		The account specified must exist in the database, otherwise an exception is raised.
		"""
		
		account = self.__accounts.get( str(Aid), None)
		
		old = account['Aamount']
		account['Aamount'] = old + amount
		
		self.log.raw(self.log_string('Deposit', Aid, old, old+amount,account['Version'],account['State']))
		

	def Withdrawal( self, Aid, amount ):
		"""
		Withdrawal( Aid, amount )
		This method withdraw a specified amount to an account designated. Both variables are given as parameter.
		The account specified must exist in the database, otherwise an exception is raised.
		If the amount indicated will lead to a negative balance in the account specified, this operation is not performed and an exception is raised.
		"""
		account = self.__accounts.get( str(Aid), None)
		
		old = account['Aamount']
		result = old - amount

		account['Aamount'] = result

		self.log.raw(self.log_string('Withdrawal', Aid, old, result,account['Version'],account['State']))

	def DepositInterest( self, Aid, rate ):
		"""
		DepositInterest( Aid, rate )
		This method applies the stated interest rate on the account specified.
		The rate should be a float number between 0 and 1.
		The account specified must exist in the database, otherwise an exception is raised.
		"""

		account = self.__accounts.get( str(Aid), None)
		
		old = account['Aamounot']
		amount = old * rate
		account['Aamount'] += amount
		
		self.log.raw(self.log_string('Interest',Aid,old,old+amount,account['Version'],account['State']))

	def UpdateAccount( self, Aid, timeOfBegin, amount, version, state, logging = True ):
		"""
		UpdateAccount( Aid, timeOfBegin, amount )
		When a new server wants to join the server network, this method is needed to update the existing accounts on the new server.
		The account specified must exist in the database, otherwise an exception is raised.
		"""
		account = self.__accounts.get( str(Aid), None)

		if logging:
			self.log.raw(self.log_string('Update',Aid,account['Aamount'],amount,account['Version'],state))
		
		account['Version'] = int(version)
		account['Aamount'] = float(amount)
		account['AdateOfBegin'] = float(timeOfBegin)
		account['State'] = state

	def SimpleUpdate( self, type, Aid, amount, version, state, logging=True ):
		"""
		UpdateAccount( Aid, timeOfBegin, amount )
		When a new server wants to join the server network, this method is needed to update the existing accounts on the new server.
		The account specified must exist in the database, otherwise an exception is raised.
		"""

		account = self.__accounts.get( str(Aid), None)

		if logging:
			self.log.raw(self.log_string(type,Aid,account['Aamount'],amount,account['Version'],state))
		
		account['Version'] = int(version)
		account['Aamount'] = float(amount)
		account['State'] = state


		
	def TimeUpdate( self, Aid, begintime):
		"""
		"""
		account = self.__accounts.get( str(Aid), None)
		account['AdateOfBegin'] = float(begintime)

		
	def ScheduleInterest( self ):
		for Aid in self.GetAccountIDs():
			self.__interestRate.ScheduleDeposit( Aid )

	def logExists( self, num ):
		return path.exists(self.vars['LogPath']+str(num)+'.log')

	def RollBack( self, num ):
		checkpoint = list() #list with checkpoint contents
		log = list() #list with operations logged
		try:
			file = open(self.vars['LogPath'] + str(num) + '.log',"r")
		except:
			return None

		checkpoint = list()
		messages = list()
		start = False
		for line in file:
			items = line.strip('\n').strip('\r').split('\t')
			if items[0] == '##':
				if not start:
					start = True
				else:
					start = False
				continue
			elif items[0] == '$$':
				continue
			elif start:
				checkpoint.append(items)
			else:
				messages.append(items)

		return {'CheckPoint':checkpoint,'Operations':messages}

		
	def CheckPoint( self, StartNew ):
		"""
		This method saves to file a new bank state called checkpoint
		"""
		#Starts a new file
		if StartNew:
			self.__NewLog()
		accountsinfo=[]
		self.log.raw('##\t' + str(self.vars['LogNum']) + '\n')
		for Aid in self.GetAccountIDs():
			account = self.__accounts.get( str(Aid), None)
			self.log.raw(str(Aid) + "\t" + str( format(account['Aamount'], '.2f') ) + "\t" + str(account['Version']) + "\t" + str(account['State']) + "\t" + str(account['AdateOfBegin']) + '\n')
		self.log.raw('##\t' + str(self.vars['LogNum']) + '\n')
		self.__writelogdata()
	
	
	def log_string( self, type, Aid, oBalance, nBalance, version, state):
		self.vars['OpNum']+=1
		self.vars['TranNum']+=1
		line = str(self.vars['OpNum']) + "\t" + type + "\t" + str(Aid) + "\t" + str(oBalance) + "\t" + str(nBalance) + "\t" + str(version) + "\t" + str(state) + "\n"
		self.__writelogdata()
		return line



class InterestRateManager:
	"""
	Interest rate is bank service that periodically deposits an interest amount to each account in the database based on some fixed rate.
	
	It is taken into account that there exist several replicas of the database so there is an instance of the class in each one, however, only one of them is running.
	Thus, it is provided a method to set the writing or not of the interest rate that allows for a scheduler thread to not make any write operation in the parent database.
	"""

	#DEFAULT VALUES
	DEFAULT_PERIOD = 10
	"""(in seconds)"""
	DEFAULT_RATE = 0.05

	def __init__( self, *args):
		self.__interestRate = _InterestRateManager( *args )

	def close( self ):
		"""
		close()
		This method close's and join's the thread responsible for the deposit of interest rate.
		"""
		self.__interestRate.close()

	def Switch( self, flag=True ):
		"""
		Switch( flag=True )
		This method turns On/Off the interest rate manager of this database.
		"""
		self.__interestRate.Switch( flag )

	def ScheduleDeposit( self, Aid ):
		"""
		ScheduleDeposit( Aid )
		When a new account is created, this method is used to schedule the future deposit of interest rate.
		"""
		self.__interestRate.ScheduleDeposit( Aid )


class _InterestRateManager( Thread ):

	#DEFAULT VALUES
	DEFAULT_PERIOD = InterestRateManager.DEFAULT_PERIOD
	"""(in seconds)"""
	DEFAULT_RATE = InterestRateManager.DEFAULT_RATE

	def __init__( self, accounts, depositInterest, rate = 0.05 ):
		self.DEFAULT_RATE = rate
		Thread.__init__( self )
		self.__accounts = accounts
		self.__handler = depositInterest
		self.__schedule = []
		self.__lock = Lock()
		self.__terminateFlag = False
		self.__profetEvent = Event()
		self.__writeFlag = False
		self.start()

	def Switch( self, flag=True ):
		self.__writeFlag = flag

	def ScheduleDeposit( self, Aid ):
		if not self.__schedule:
			flag = True
		else:
			flag = False
		begining = self.__accounts[ str(Aid) ][ 'AdateOfBegin' ]
		self.__lock.acquire()
		self.__schedule.append( [ Aid, begining, 0 ] )
		self.__lock.release()
		if flag:
			self.__profetEvent.set()

	def close( self ):
		self.__terminateFlag = True
		self.__profetEvent.set()
		self.join()

	def __CalcTimeToNext( self ):
		timeToWait = time()-self.__schedule[0][1]
		n = int( timeToWait / self.DEFAULT_PERIOD )
		if n > self.__schedule[0][2]:
			return 0
		else:
			timeToWait = timeToWait%self.DEFAULT_PERIOD
			timeToWait = self.DEFAULT_PERIOD-timeToWait
			return timeToWait

	def __applyRotationInterest( self ):
		self.__lock.acquire()
		event = self.__schedule.pop(0)
		if self.__writeFlag:
			self.__handler( str( event[0] ), self.DEFAULT_RATE )
		event[2] += 1
		self.__schedule.append( event )
		self.__lock.release()

	def __deleteInterest( self ):
		self.__lock.acquire()
		self.__schedule.pop( 0 )
		self.__lock.release()

	def run( self ):
		while True:
			#Thread waits for event or timeout
			if self.__schedule:
				timeToWait = self.__CalcTimeToNext()
				self.__flag = True
				self.__profetEvent.clear()
				self.__profetEvent.wait( timeToWait )
			else:
				self.__flag = False
				self.__profetEvent.clear()
				self.__profetEvent.wait()
			
			if self.__profetEvent.is_set():	#Close, First ScheduleDeposit
				if self.__terminateFlag:
					break
			else:	#timeout
				if self.__accounts.get( str( self.__schedule[0][0] ), None ) is None:
					self.__deleteInterest()
				else:
					self.__applyRotationInterest()


class AccountsLockDynamic:
	"""
	This class preserves corectness of transactions by deducting money from an account only when it is available.
	This allows the database to be multithreaded and accept requests concurrently.
	"""

	def __init__( self ):
		self.__entitys = {}
		self.__lock = None
		self.__empty = None
		self.__access = True

	def close( self ):
		"""
		close()
		This method close's the object responsible for the mutual exclusion in the accounts.
		"""
		#closing procedures are implemented here
		pass

	def WaitUntilEmpty( self ):
		"""
		WaitUntilEmpty()
		Waits until alls accounts locked to be unlocked. This method is used when the server network needs to make a critical procedure.
		"""
		if self.__empty is not None:
			self.__empty.wait()

	def GrantAccess( self, flag=True ):
		"""
		GrantAccess( flag=True )
		This method turns On/Off the access to the centralized mutual exclusion mecanism.
		"""
		self.__access = flag

	def acquire( self, entity, Id ):
		"""
		acquire( self, entity, Id ) -> If True then the acquire was successful, otherwise means the access to the centralized mutual exclusion was not granted.
		Used like the method from threading.Lock.acquire but applied to an account.
		"""
		if not self.__access:
			return False
		
		if self.__lock is None:
			self.__lock = Lock()
		if self.__empty is None:
			self.__empty = Event()
		self.__lock.acquire()
		token = self.__Read( entity, Id, True)
		token[1] += 1
		self.__lock.release()
		
		token[0].acquire()
		token[1] -= 1
		
		return True

	def release( self, entity, Id ):
		"""
		release( self, entity, Id ) -> If True then the release was successful, otherwise means the access to the centralized mutual exclusion was not granted.
		Used like the method from threading.Lock.release but applied to an account.
		"""
		if not self.__access:
			return False
		
		self.__lock.acquire()
		lock = self.__Read( entity, Id, False )
		self.__lock.release()
		lock.release()
		if not self.__entitys:
			temp = self.__lock
			self.__lock = None
			del temp
			self.__empty.set()
			temp = self.__empty
			self.__empty = None
			del temp
		
		return True

	def __Read( self, entity, Id, Assign ):
		entityName = str( entity )
		entityId = str( id(entity) )
		
		entity = self.__entitys.get( entityId, None )
		if entity is None:
			if Assign:
				self.__entitys[ entityId ] = {}
				entity = self.__entitys[ entityId ]
			else:
				raise ValueError( "The entity provided does not have any lock assigned: "+entityName )
		
		token = entity.get( str( Id ), None )
		if token is None:
			if Assign:
				entity[ str( Id ) ] = [ Lock(), 0 ]
				token = entity[ str( Id ) ]
			else:
				raise ValueError( "The id provided does not have a lock assigned: "+str(Id)+" from "+entityName )
		
		if not Assign:
			waiting = token[1]
			token = token[0]
			if waiting is 0:
				temp = entity.pop( str(Id) )
				del temp
				if not entity:
					temp = self.__entitys.pop( entityId )
					del temp
		
		return token


class AccountsLock:
	def __init__( self ):
		self.__entitys = {}
		self.__dictLock = Lock()
		self.__incLock = Lock()
		self.__counter = 0
		self.__empty = Event()
		self.__empty.set()
		self.__access = True

	def NewAccount( self, Aid ):
		self.__dictLock.acquire()
		self.__entitys[str(Aid)] = Lock()
		self.__dictLock.release()

	def __getLock( self, Aid ):
		self.__dictLock.acquire()
		lock = self.__entitys.get( str(Aid), None )
		self.__dictLock.release()
		return lock

	def __countInsiders( self, flag ):
		self.__incLock.acquire()
		previous = self.__counter
		if flag:
			self.__counter += 1
		else:
			self.__counter -= 1
		if self.__counter == 1 and previous == 0:
			self.__empty.clear()
		elif self.__counter == 0 and previous == 1:
			self.__empty.set()
		self.__incLock.release()

	def __action( self, Aid, flag ):
		if not self.__access and flag:
			return False
		lock = self.__getLock( Aid )
		if lock is None:
			return 'The acount id provided does not exist.'
		elif flag:
			lock.acquire()
		else:
			if lock.locked():
				lock.release()
		self.__countInsiders( flag )
		return True

	def acquire( self, Aid ):
		return self.__action( Aid, True )

	def release( self, Aid ):
		return self.__action( Aid, False )

	def close( self ):
		self.__entitys.clear()

	def WaitUntilEmpty( self ):
		"""
		WaitUntilEmpty()
		Waits until alls accounts locked to be unlocked. This method is used when the server network needs to make a critical procedure.
		"""
		self.__empty.wait()

	def GrantAccess( self, flag=True ):
		"""
		GrantAccess( flag=True )
		This method turns On/Off the access to the centralized mutual exclusion mecanism.
		"""
		self.__access = flag
		if not flag:
			self.WaitUntilEmpty()


if __name__ == '__main__':
	print 'inicio'
	d = DataBaseBank()
	i = d.GetInterestRate()
	i.Switch()
	d.NewAccount(100,1)
	from time import sleep
	sleep(2)
	print d.GetAccount(1)
