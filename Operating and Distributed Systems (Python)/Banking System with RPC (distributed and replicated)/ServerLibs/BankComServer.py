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

from DataBase import DataBaseBank
from time import ctime, time, sleep
from threading import Thread, Event, Lock
import Pyro.core


def GetOtherBanks( ns, group, name ):
	"""
	Function used to find remote servers.
	"""
	if ns is None:
		return 'Error: A proxy to NameServer needs to be created first.'
	
	def receivesList( ns ):
		delay = 1
		while True:
			try:
				uriAll = ns.flatlist()
				break
			except:
				pass
			#if self.__options['verbose']:
			print 'Error: connection to NameServer.'
			print 'Retrying in', delay,'second(s). Press <CTRL+C> to abort, though it \'s not advisable.'
			sleep( delay )
			if delay < 20:
				delay = delay * 2
			else:
				delay = 20
		return uriAll
	
	try:
		uriAll = receivesList( ns )
	except KeyboardInterrupt:
		print
		return 'Aborted'
	
	banks = []
	for fullname, value in uriAll:
		fullname = fullname.split('.')
		if	fullname[0] == group and fullname[1] == 'Private' and fullname[2] != name:
			try:
				proxy = Pyro.core.getProxyForURI(value)
			except:
				continue
			banks.append({'Name': fullname[2],'URI': value,'Proxy':proxy})
	
	return banks


class Bully( object ):

	def __init__( self, nsPROXY, coordinatorURI, lastElected, lastAttempt, gate, options, unleash ):
		self.__ns = nsPROXY
		self.__coordinator = coordinatorURI
		self.__lastElected = lastElected
		self.__lastAttempt = lastAttempt
		self.__options = options
		self.__gate = gate
		self.__waiting = Event()
		self.__unleash = unleash

	def __strdecIP( self, ip ):
		"""
		Converts a string with an IPv4 address to a decimal integer
		"""
		fields = ip.split('.')
		return int(fields[0])*(256**3)+int(fields[1])*(256**2)+int(fields[2])*(256)+int(fields[3])

	def __getElectors( self ):
		"""
		Obtains the banks in the NS that have an ID (IP) that is
		greater than the servers IP.
		"""
		if self.__ns is None:
			return 'Error: A proxy to NameServer needs to be created first.'
		
		others = GetOtherBanks( self.__ns, self.__options['group'], self.__options['name'] )
		if isinstance( others, str ):
			return others
		
		myIP = self.__strdecIP( self.__options['serverHostname'] )
		myRegTime = self.__ns.getMeta( 'Private.' + self.__options['name'] )
		
		banks = []
		for bank in others:
			bankIP = self.__strdecIP( bank['URI'].address )
			if bankIP > myIP:
				try:
					banks.append( ( bank['Name'], Pyro.core.getProxyForURI( bank['URI'] ) ) )
				except:
					return 'Error: unable to get server proxy.'
			elif bankIP == myIP:
				bankRegTime = self.__ns.getMeta( 'Private.' + bank['Name'] )
				if bankRegTime < myRegTime:
					try:
						banks.append( ( bank['Name'], Pyro.core.getProxyForURI( bank['URI'] ) ) )
					except:
						return 'Error: unable to get server proxy.'
		return banks

	def __victory( self, ID ):
		#TODO:
		#	OBTAIN lastelected from everyone
		#	OBTAIN states from everyone

		if self.__lastElected == ID:
			self.__coordinator = None
			self.__lastElected += 1
			
			if self.__options['verbose']:
				print 'Im the new coordinator!'
				print 'Next electiondID is:', self.__lastElected
			
			banks = GetOtherBanks( self.__ns, self.__options['group'], self.__options['name'] )
			if isinstance(banks,str):
				if self.__options['verbose']:
					print 'ERROR: NS FAIL'
				return banks

			#allows requests
			self.__gate(True)
			
			for each in banks:
				if self.__options['verbose']:
					print 'Sending I won to:', each['Name'],'with election ID:', self.__lastElected
				uri=self.__ns.resolve('Private.' + self.__options['name'])
				try:
					each['Proxy'].iWon( uri, self.__lastElected )
				except:
					pass #Don't care :)
			
			if self.__options['verbose']:
				print 'Allows access to new requests to the servers'
				print '---'
		else:
			if self.__options['verbose']:
				print '( Bully redundancy )'
			pass

	def __electing( self ):
		if self.__options['verbose']:
			print 'Waiting for iWon...'
		self.__waiting.wait(5)
		
		if self.__waiting.isSet():
			self.__waiting.clear()
			
			if self.__options['verbose']:
				print 'New coordinator was elected! next electiondID is:', self.__lastElected 
				print '---'
		else:
			self.__coordinator = None
			#allows requests
			self.__gate(True)
			if self.__options['verbose']:
				print 'ERROR: No reply, a new election should start from here.'

	def getCoordinator( self ):
		"""
		This method allows for a quick answer on who is the coordinator. The server will reply with a tuple
		containing True or False and the Name of the coordinator
		"""
		#The receiver knows that if (self.__coordinator is None) then {this is the coordinator}
		self.__waiting.wait()
		return self.__coordinator

	def getElectionID( self ):
		"""
		getElectionID() -> The next election id to this server.
		"""
		return self.__lastElected

	def isCoordinator( self ):
		"""
		Returns True if this server is the coordinator, false otherwise.
		"""
		return self.__coordinator == None

	def SetLastAttempt( self ):
		self.__lastAttempt = self.__lastElected

	def iWon( self, uri, ID ):
		"""
		Sets the private event that allows the continuation of the server
		"""
		if self.__options['verbose']:
			print 'Received I won from coordinator @',uri.address
		self.__coordinator = uri
		#TODO: rever a atribuição do electionId
		#self.__lastelected = ID-1
		self.__lastElected = ID
		self.__waiting.set()
		self.__gate(False)
		self.__unleash.set()

	def election( self, ID ):
		"""
		This method allows any server to start an election procedure.
		First it starts by pulling from the nameserver all of the current servers, obtaining a proxy
		for each one that has an ID (ip) greater than its. If it is able to reach the other servers
		then it waits for an I won message (for 20 s). If time runs out, the server declares itself 
		as the coordinator.
		"""
		if self.__options['verbose']:
			print 'Election ID: ',ID
		
		if self.__waiting.isSet():
			self.__waiting.clear()
		
		electors = self.__getElectors()
		if isinstance( electors, str ):
			return electors
		
		nokCounter = 0
		for each in electors:
			try:
				each[1]._setOneway("election")
				each[1].election( ID )
			except:
				nokCounter += 1
		
		if not electors or len(electors) == nokCounter:
			self.__victory( ID )
		else:
			self.__electing()

		self.__waiting.set()


class ServerToServerAPI ( Pyro.core.ObjBase, Bully ):

	def __init__( self, nsProxy, coordinatorURI, lastElected, lastAttempt, dataBase, options ):
		Pyro.core.ObjBase.__init__(self)
		self.__unleash = Event()
		self.__unleash.clear()
		Bully.__init__( self,
						nsProxy,
						coordinatorURI,
						lastElected,
						lastAttempt,
						dataBase.GetAccountsLock().GrantAccess,
						options,
						self.__unleash )
		
		self.__ns = nsProxy
		self.__dataBase = dataBase
		self.__options = options
		self.__commit = Event()
		self.__waitcheckpoint = Event()
		self.__state = 'Init'
		self.__commitThread = None
		self.__localOp = dataBase.vars['OpNum']+1

	def __getUpdates(self):
		Aliststr = []
		for Aid in self.__dataBase.GetAccountIDs():
			account = self.__dataBase.GetAccount(Aid)
			Aliststr.append(	(
								Aid,
								account['AdateOfBegin'],
								float( format( account['Aamount'], '.2f') ),
								account['Version'],
								account['State']
								)
							)
		return Aliststr


	def getInterestTime(self):
		Aliststr = []
		for Aid in self.__dataBase.GetAccountIDs():
			account = self.__dataBase.GetAccount(Aid)
			Aliststr.append((Aid,account['AdateOfBegin']))
		return Aliststr

	def sync( self, Epoch, OpNum, Name, lastop):
		"""
		This method is called in the coordinator by a new server that enters the system, in order to start the synchronization
		of the databases. This is achieved by blocking requests and waiting for current ones to finish and commit.
		The coordinator is then responsible to issue the updates to the new server and waits for it to start
		an election.
		"""
		if not self.isCoordinator():
			return 'This server is not the coordinator.'
		
		accountsLock = self.__dataBase.GetAccountsLock()
		accountsLock.GrantAccess(False) #Blocks everyone
		if self.__options['verbose']:
			print 'Block clients access to the system.'


		###NEEDS TO SET ORDER IN TIME TO GRANT ACCESS AGAIN IN CASE OF SYSTEM FAILURE!
		if Epoch == self.__dataBase.vars['LogNum']:
			if OpNum == self.__dataBase.vars['OpNum']:
				#Server Up To date
				if self.__options['verbose']:
					print 'You\'re updated! Come on and join us!'
				return None, False
			#probably, the most common case (spontaneous and momentary fail)
			else:
				##send only the new updates
				log = self.getRoll(Epoch)
				updates = []
				for line in log['Operations']:
					if int(line[0]) > int(lastop):
						print 'REMOTE LOG',line, 'NUM',line[0],':',lastop
						#OpNum[0] type[1] Aid[2]  oBalance[3]  nBalance[4] version[5] state[6]
						updates.append(	(line[1],
										int(line[2]),
										float( line[4] ),
										line[5],
										line[6]
										))
				return updates, False
		else:
			return self.__getUpdates(), True


				#others = GetOtherBanks( self.__ns, self.__options['group'], self.__options['name'] )
				#print 'OTHER:',others
				##try:
					#for bank in others:
						#(bank['Proxy'],bank['Proxy'].getRoll(Epoch)['Operations'])
				#except:
					#pass #don't care if it fails

				##Get my log
				#mylog = getRoll(Epoch)
				#callerupdates = []
				#networkupdates = []
				##Compares logs and send updates
				#for myline in mylog:
					##compare with network
					#if caller[1]:
						#callline = caller[1].pop()
						#cmp = self.__compare(myline,callline)
						#if cmp == 0:
							#continue
						#elif cmp > 0:
							#print 'Network version is the most accurate one'
							#callerupdates.append(myline)
							#continue
						#elif cmp < 0:
							##For future development
							##print 'Remote version is greater than mine'
							##networkupdates.append(callline)
							#continue
				##Append the rest of my messages
				#callerupdates.append(myline)
				
		### For future use
		#elif Epoch < self.__dataBase.vars['LogNum']:
			#others = self.GetOtherBanks
			#logs = list()
			##Agree on version
			#try:
				#nbank = len(bank)
				#counter = 0
				#while True
					#for bank in others:
						#if not bank['Proxy'].hasLog(Epoch):
							#Epoch-=1
							#continue
						#else:
							#counter+=1
							#if counter == nbank:
								#break
			#except:
				#nbank-=1
			#try:
				#for bank in others:
					#logs.append({bank['Name']:(bank['Proxy'],bank['Proxy'].getRoll(Epoch))})
					#print logs
			#except:
				#pass #don't care if it fails
			##Compare logs and send updates
			#nextlog=Epoch
			#while nextlog != Epoch:
				#pass

		#elif Epoch < self.__dataBase.vars['LogNum']:
					#others = self.GetOtherBanks
					##Agree on version
					#nbank = len(bank)
					#counter = 0
					#while counter != nbank
						#for bank in others:
							#try:
								#if not bank['Proxy'].hasLog(Epoch):
									#Epoch-=1
									#continue
								#else:
									#counter+=1
							#except:
								#nbank-=1
					#return Epoch,self.__dataBase.vars['LogNum']

		##New server is more up to date than me
		#elif Epoch > self.__dataBase.vars['LogNum']:
			#for bank in others:
					#logs.append({bank['Name']:(bank['Proxy'],bank['Proxy'].getRoll(Epoch))})
					#print logs

		#	else:
		#		#Lets roll back to the begining of this Epoch
		#		for line in log['Operations']:
		#		return 'Let me check',(False)
		#else:
		#	#Start from the Epoch the server indicated
		#	return 'Man... You were living under a rock!',(False)


	def doCheckpoint(self):
		self.__dataBase.CheckPoint(True)

		
	def __compare( self, myline, callline):
		#OpNum type Aid oBalance nBalance version[5] state + "\n"
		if myline[0] == callline[0]:
			if myline[1] == callline[1]:
				if myline[5] == callline[5]:
					return 0, None
				elif int(myline[5]) > int(callline[5]):
					return 1, myline
				else:
					return -1, callline
			else:
				#he lost a message
				return 1,myline
		else:
			pass #it will not happen (the count is equal)


	def getRoll(self, n):
		return self.__dataBase.RollBack(n)

	def hasLog(n):
		return self.__dataBase.logExists( n )

	def update(self, Aid, amount, type, source='unknown', ToAid = None):
		"""
		Method used by a remote server, to commit an update to the local database
		"""
		if type == 'Withdraw':
			try:
				Aid = self.__dataBase.Withdrawal( Aid, amount )
				rsp = 'Withdrew ' + str(amount) + '€ in account ' + str(Aid)
			except KeyError, error:
				rsp = error
			except ValueError, error:
				rsp = error
		
		elif type == 'Deposit':
			try:
				self.__dataBase.Deposit( Aid, amount )
				rsp = 'Deposited ' + str(amount) + '€ in account ' + str(Aid)
			except KeyError,error:
				rsp = error
			except ValueError, error:
				rsp = error
		
		elif type == 'Transfer':
			try:
				self.__dataBase.Withdrawal( Aid, amount )
			except KeyError, error:
				rsp = error
			except ValueError, error:
				rsp = error
			
			try:
				toAid = self.__dataBase.Deposit( ToAid, amount )
				rsp = 'Transfered '+ str(amount) + '€ from ' + str( Aid ) + ' to ' + str( ToAid )
			except KeyError,error:
				#This is the only possible error: ToAid doesn't belong to any account.
				#The next line will NOT generate an exception.
				self.__dataBase.Deposit( Aid, amount )
				rsp = '[Error on transfer] '+error
		
		if self.__options['verbose']:
			print 'Update:', rsp
		return rsp

	def networkTransaction( self, Aid, amount, type, source='unknown', ToAid = None):
		"""
		#TODO: CHANGE
		Deposit(  Aid, amount )
		Deposit a specified amount to an account designated. Both variables are given as parameter.
		A remote coordinator is contacted to allow the execution of the deposit. Afterwards, the
		deposit is done locally and system wide. Finally the coordinator is once again contacted to
		allow other to execute deposits.
		The account specified must exist in the database, otherwise an exception is raised.
		"""

		### TODO: DELETE
		if type == 'Test':
			print 'chekpoint'
			self.__dataBase.CheckPoint()
			print 'chekpoint done'
			return True

		##Sanity tests
		try:
			account = self.__dataBase.GetAccount( Aid )
		except:
			return 'Account does not exist'
		if ToAid:
			if ToAid == Aid:
				return 'Accounts must be different'
			try:
				Toaccount = self.__dataBase.GetAccount( Aid )
			except:
				return 'Account does not exist'
		
		#Acquire centralized lock
		coordinator = self.getCoordinator()
		if coordinator:
			coordinator = Pyro.core.getProxyForURI( coordinator )

		#TODO: CAUTELA COM O RSP. SE FOR FALSE ENTÃO O LOCK NÃO FICOU FEITO
		rsp = self.acquireMutual( Aid, coordinator )
		if self.__options['verbose']:
			print 'Attention! Acquired returned:',rsp

		if isinstance( rsp, str ):
			return rsp
		
		transaction = {'Aid':Aid, 'amount':amount, 'type': type, 'source': source, 'ToAid': ToAid}
			
		if type == 'Balance':
			status = self.__networkRead( coordinator, transaction )
		else:
			status = self.__networkWrite(coordinator, transaction )

		#Acquire centralized lock
		rsp = self.releaseMutual(Aid, coordinator)
		if self.__options['verbose']:
			print 'Attention! Acquired returned:',rsp		
		return status

	def __networkWrite( self, coordinator, transaction ):

		try:
			account = self.__dataBase.GetAccount(transaction['Aid'])
		except:
			#TODO
			pass
		
		###Starting 3PC
		if coordinator:
			rsp=coordinator.requestCommit( account['Version'], transaction )
			if isinstance(rsp, str):
				return 'Failed to commit'
		else:
			rsp=self.requestCommit( account['Version'], transaction )
			if isinstance(rsp, str):
				return 'Failed to commit'
		if self.__options['verbose']:
			print 'Finished network Write'
		return None # this line is not needed

	def __networkRead( self, coordinator, transaction ):


		### Do it with another server, to detect failure

		
		if self.__options['verbose']:
			print 'Reading account',transaction['Aid']

		#NOTE: quorom base protocol = ROWA ( read-one / write-all )
		try:
			account = self.__dataBase.GetAccount( transaction['Aid'] )
		except KeyError, error:
			return error
		
		return 'Balance: %.2f'%account['Aamount']

	def acquireMutual( self, Aid, coordinator ):
		"""
		acquireMutual(self, Aid)
		Provides synchronous access to the the account specified by Aid.
		The allowance is only provided by the coordinator. 
		"""
		if self.isCoordinator():
			if self.__options['verbose']:
				print 'Getting local lock for account',Aid
			accountsLock = self.__dataBase.GetAccountsLock()
			rsp = accountsLock.acquire( Aid )
		else:
			if self.__options['verbose']:
				print 'Getting remote lock ( at the coordinator) for account', Aid
			try:
				rsp = coordinator.acquireMutual( Aid, None )
			except:
				# re-eleição
				electionID = self.getElectionID()
				self.election( electionID )
				coordinator = self.getCoordinator()
				if coordinator:
					coordinator = Pyro.core.getProxyForURI( coordinator )
				# efectuar pedido ao novo coordenador
				return self.acquireMutual( Aid, coordinator )

		if not rsp:
			self.__unleash.wait()
			self.__unleash.clear()
			#Get new proxy
			coordinator = self.getCoordinator()
			if coordinator:
				coordinator = Pyro.core.getProxyForURI( coordinator )
			rsp = self.acquireMutual( Aid, coordinator )

		if self.__options['verbose']:
			if not isinstance( rsp, str ):
				print 'Lock done'
		
		return rsp

	def releaseMutual( self, Aid, coordinator ):
		"""
		releaseMutual(self, Aid)
		Releases the lock on the account specified by Aid.
		This is only done by the coordinator.
		"""
		if self.isCoordinator():
			if self.__options['verbose']:
				print 'Releasing local lock for account', Aid
			accountsLock = self.__dataBase.GetAccountsLock()
			rsp = accountsLock.release( Aid )
		else:
			if self.__options['verbose']:
				print 'Releasing remote lock (at the coordinator) for account', Aid
			try:
				rsp = coordinator.releaseMutual( Aid, None )
			except:
				return 'Error while releasing remote lock for account '+str(Aid)

		###Release at the new coordinator if it is the same
		if not rsp:
			self.__unleash.wait()
			self.__unleash.clear()
			newcoordinator = self.getCoordinator()
			if coordinator:
				newcoordinator = Pyro.core.getProxyForURI( newcoordinator )
			if coordinator == newcoordinator:
				rsp = self.releaseMutual( Aid, coordinator )

		if self.__options['verbose']:
			if isinstance( rsp, str ):
				return rsp
			else:
				print 'Unlock done'

		return rsp


###########
	#	3PC Methods
	#	TODO: Block local database
	def __sendtolog(self, msg):
			DataBaseBank.writelock.acquire()
			self.__dataBase.log.raw(msg)
			DataBaseBank.writelock.release()

	def requestCommit(self, id, transaction):
		"""
		Starts the 3PC protocol
		"""
		#Sanity test
		if not self.isCoordinator():
			return 'This server is not the coordinator.'

		#Obtains the other banks on the name server
		others = GetOtherBanks( self.__ns, self.__options['group'], self.__options['name'] )
		if isinstance( others, str ):
			return others

		#Does a checkpoint if needed
		if self.__dataBase.vars['OpNum'] > DataBaseBank.threshold:
			if self.__options['verbose']:
				print 'Doing Checkpoint'
			if DataBaseBank.writelock.acquire(False):
				self.startCheckpoint(others)
				self.__localOp=1
				flag = True
				self.__waitcheckpoint.set()
				DataBaseBank.writelock.release()
			else:
				self.__waitcheckpoint.wait()
				self.__waitcheckpoint.clear()

		##starts transaction
		if transaction['ToAid']:
			self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+transaction['type'] + '\t' + str(transaction['Aid']) + '\t' + str(transaction['amount']) + '\t' + transaction['ToAid'] + '\t' + str(id)+'\n' )
		else:
			self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+transaction['type'] + '\t' +str(transaction['Aid']) + '\t' + str(transaction['amount']) + '\t' + str(id) + '\n' )
		account = self.__dataBase.GetAccount(transaction['Aid'])
		account['State']='Init'
		#Obtain consensus from the servers
		if self.__options['verbose']:
			print 'CanCommit version',id,'?'
		self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+'Request Commit\n')
		nokcounter=0
		for bank in others:
			try:
				res = bank['Proxy'].canCommit( id, transaction )
				if res == 'NO':
					nokcounter+=1
			except:
				#start new election?
				nokcounter+=1
		
		if nokcounter >=1:
			for bank in others:
				try:
					bank['Proxy'].abort( transaction['Aid'] )
				except:
					pass
			self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+'Request Abort\n')
			account['State']='Aborted'
			return 'Aborted'
		else:
			#enters precommit
			account['State']='PreCommit'
			if self.__options['verbose']:
				print 'PreCommit with version',id
			self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+'Request PreCommit\n')
			for bank in others:
				try:
					bank['Proxy'].preCommit( transaction['Aid'] )
				except:
					#start new election?
					nokcounter+=1

			if nokcounter >=1:
				for bank in others:
					try:
						bank['Proxy'].abort( transaction['Aid'] )
					except:
					#start new election?
						pass
				account['State']='Aborted'
				self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+'Request Abort\n')
				return 'Aborted'
			else:
				#enters commit
				if self.__options['verbose']:
					print 'Commit with version',id

				self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+'Commit\n')
				for bank in others:
					try:
						bank['Proxy'].doCommit( transaction['Aid'] )
					except:
						if self.__options['verbose']:
							print 'Commit not done'
						return 'Commit Not Done'
				
				#Do update on itself
				
				account['State']='Commit'
				rsp = self.update( transaction['Aid'],
									 transaction['amount'],
									 transaction['type'],
									 transaction['source'],
									 transaction['ToAid'] )
				account['Version']+=1
				if self.__options['verbose']:
					print 'New account version:',account['Version']
					print rsp

		DataBaseBank.writelock.acquire()
		self.__localOp+=1
		DataBaseBank.writelock.release()

		return None


	def setAccess(self, Flag):
		locks = self.__dataBase.GetAccountsLock()
		locks.GrantAccess(Flag)


	def startCheckpoint(self,banks):
		#Does checkpoint
		for bank in banks:
			try:
				bank['Proxy'].doCheckpoint()
			except:
				pass
		self.doCheckpoint()

	def canCommit( self, id, transaction ):
		if transaction['ToAid']:
			self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+transaction['type'] + '\t' + str(transaction['Aid']) + '\t' + str(transaction['amount']) + '\t' + transaction['ToAid'] + '\t' + str(id)+'\n' )
		else:
			self.__sendtolog('$$\t'+str(self.__localOp)+'\t'+transaction['type'] + '\t' +str(transaction['Aid']) + '\t' + str(transaction['amount']) + '\t' + str(id) + '\n' )
		self.__sendtolog('$$\t'+ str(self.__localOp)+'\t'+'Request Commit\n')
		account = self.__dataBase.GetAccount(transaction['Aid'])
		account['State']='Init'
		if self.__options['verbose']:
			print 'I\'got version',account['Version'],'\nIt has: ',id
		th = CommitThread(id,transaction,self.__dataBase,self.update,self.__options['verbose'],self.__localOp)
		self.__commitThread = th.waituntilstarted
		self.__commitThread.wait()
		self.__commitThread.clear()
		if account['Version'] == id:
			return 'YES'
		else:
			return 'NO'

	def preCommit( self, Aid ):
		self.__sendtolog('$$\t'+ str(self.__localOp)+'\t'+'Request PreCommit\n')
		account = self.__dataBase.GetAccount(Aid)
		account['State']='PreCommit'
		account['Event'].set()
		if self.__options['verbose']:
			print 'preCommit done'

	def doCommit( self, Aid ):
		self.__commitThread.wait(5)
		if self.__commitThread.isSet():
			self.__commitThread.clear()
		else:
			self.__dataBase.log.raw('$$\t'+ str(self.__localOp)+'\t'+'Aborted\n')
			return 'Abort'
		self.__sendtolog('$$\t'+ str(self.__localOp)+'\t'+'Commit\n')
		account = self.__dataBase.GetAccount(Aid)
		account['State']='Commit'
		account['Event'].set()
		if self.__options['verbose']:
			print 'doCommit done'

	def abort( self, Aid ):
		self.__dataBase.log.raw('$$\t'+ str(self.__localOp)+'\t'+'Request Abort\n')
		account = self.__dataBase.GetAccount( Aid )
		account['State'] = 'Abort'
		account['Event'].set()

	def getState( Aid ):
		account = self.__dataBase.GetAccount( Aid )
		return account['State']



class CommitThread( Thread ):
	###
	# TODO: Thread safe access to objects
	# set from precommit and se from commit done before waiting

	def __init__( self, id, transaction, dataBase, update, verbose, OpNum ):
		Thread.__init__( self )
		self.timeout = 5
		self.waituntilstarted = Event()
		self.waituntilstarted.clear()
		self.__id = id
		self.__transaction = transaction
		self.__update = update
		self.__verbose = verbose
		self.__log = dataBase.log.raw
		self.__account = dataBase.GetAccount(transaction['Aid'])
		self.__accountLock = dataBase.GetAccountsLock()
		self.__account['Event'].clear()
		self.__accountLock.acquire( transaction['Aid'] )
		self.__OpNum = OpNum
		self.start()

	def run( self ):
		#Ready state
		self.waituntilstarted.set()
		self.__account['State']='Ready'
		if self.getreply():
			self.waituntilstarted.set()
			if self.__verbose:
				print 'Thread enters PreCommit'
			self.__account['State']='PreCommit'
			if self.getreply():
				if self.__verbose:
					print 'Thread enters Commit'
				self.__Commit()
		#Terminates
		self.close()

	def getreply( self ):
		if self.__verbose:
			print 'Thread waiting'
		self.__account['Event'].wait(self.timeout)
		if self.__account['Event'].isSet():
			self.__account['Event'].clear()
			if self.__verbose:
				print 'Event was setted'
			if self.__account['State'] is 'Abort':
				if self.__verbose:
					print 'Abort'
				return False
		else:
			if self.__account['State'] is 'Ready':
				self.__account['State']='PreAbort'
				if self.__verbose:
					print 'Aborting from Ready'
				self.__log('$$\t'+ str(self.__OpNum)+'\t'+'Aborted\n')
				return False
			elif self.__account['State'] is 'PreCommit': 
				self.__account['State']='PreAbort'
				if self.__verbose:
					print 'BankComServer::TODO: I must talk to others'
					self.__log('$$\t'+ str(self.__OpNum)+'\t'+'Aborted\n')
				#return False or True
				return False
		return True

	def __Commit( self ):
		rsp = self.__update( self.__transaction['Aid'],
							 self.__transaction['amount'],
							 self.__transaction['type'],
							 self.__transaction['source'],
							 self.__transaction['ToAid'] )
		self.__account['Version']+=1
		if self.__verbose:
			if self.__verbose:
				print 'New account version:',self.__account['Version']
			print rsp
	
	def close(self):
		self.__accountLock.release( self.__transaction['Aid'] )
		if self.__verbose:
			print 'Thread exited'


class ServerToClientAPI ( Pyro.core.ObjBase ):

	def __init__( self, serverAPI, verbose ):
		Pyro.core.ObjBase.__init__(self)
		self.__verbose = verbose
		self.__serverAPI = {'doTransaction': serverAPI.networkTransaction}

	def viewBalance( self, Aid, source = 'unknown' ):
		if self.__verbose:
			print '---'
			print 'Checking balance.'
		
		rsp = self.__serverAPI['doTransaction'](Aid, None, 'Balance', source)
		if rsp is None:
			rsp = 'Unable to obtain account balance'
		
		if self.__verbose:
			print rsp
		
		return rsp

	def deposit(self, Aid, amount, source='unknown'):
		if self.__verbose:
			print '---'
			print 'Processing client deposit'
			
		rsp = self.__serverAPI['doTransaction'](Aid, amount, 'Deposit', source)
		if rsp is None:
			rsp = 'Deposited ' + str(amount) + '€ in account ' + str(Aid)
		
		return rsp

	def withdraw(self, Aid, amount, source='unknown' ):
		if self.__verbose:
			print '---'
			print 'Processing client withdrawal'
		
		rsp = self.__serverAPI['doTransaction'](Aid, amount, 'Withdraw', source)
		if rsp is None:
			rsp = 'Withdrew ' + str(amount) + '€ in account ' + str(Aid)
		
		if self.__verbose:
			print rsp
		
		return rsp

	def transfer( self, fromAid, toAid, amount, source='unknown' ):
		if self.__verbose:
			print '---'
			print 'Processing client transfer'
		
		rsp = self.__serverAPI['doTransaction'](fromAid, amount, 'Transfer', source, toAid)
		if rsp is None:
			rsp = 'Transfered '+ str(amount) + '€ from ' + str( fromAid ) + ' to ' + str( toAid )
		
		if self.__verbose:
			print rsp
		
		return rsp
	
	def test(self):
		print 'test'
		self.__serverAPI['doTransaction'](None, None, 'Test', None, None)
		print 'test done'
