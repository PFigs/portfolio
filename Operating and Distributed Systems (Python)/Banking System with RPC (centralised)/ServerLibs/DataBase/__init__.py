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
The database is composed by the following information:
- Individual profiles of bank customers (name, address, age ,...)
- Accounts registered on the bank.
- Relations that exist between accounts and bank customers, ie
  each acount may or may not belong exclusively to one client.
- History of updates in the accounts.
[ See diagram file for more detailed information. ]
"""


from time import time, ctime
from pickle import load, dump
from threading import Lock
from globalLock import GlobalLock
from InterestRate import InterestRateManager


DEFAULT_BACKUP_NAME='database.db'


class VectorStamps( object ):
	"""
	This class gives the ability to replicate data over consistent
	database objects using vector stamps.
	"""
	def __init__( self, nObjs, index ):
		if not ( isinstance( nObjs, int ) and isinstance( index, int ) ):
			raise ValueError('Can\'t create database. Parameters are not integers.')
		if nObjs<=0:
			raise ValueError('Can\'t create database. nObjs must be > 0.')
		
		self.__index = index
		self.__vectorStamps = []
		for i in range(0,nObjs):
			self.__vectorStamps.append(0)
	
	def GetVectorStamps(self):
		"""
		GetVectorStamps() -> vector stamps.
		"""
		return self.__vectorStamps
	
	def _GetStampsData(self):
		return self.__index, self.__vectorStamps
	
	def _SetStampsData(self, (index, vector) ):
		self.__index = index
		self.__vectorStamps = vector
	
	def _NewEvent(self):
		self.__vectorStamps[ self.__index ] += 1


class DataBaseBank( VectorStamps ):
	"""
	This class defines the database system.
	"""
	def __init__( self, nObjs=1, index=0):
		"""
		DB( [nObjs] [,index] )
		nObjs: indicates the total number of databases to be replicated. Default is one.
		index: indicates this database index. Default is zero.
		
		Raises ValueError if nObjs or index are not integers.
		Raises ValueError if nObjs is not bigger than zero.
		"""
		super( DataBaseBank, self ).__init__( nObjs, index )
		self.__clients = {}
		self.__accounts = {}
		self.__updates = {}
		self.__globalLock = GlobalLock()
		self.__interestRate = InterestRateManager( self.__accounts, self.DepositInterest )

	def Close( self ):
		self.__interestRate.Close()
		self.__globalLock.Close()

	def __GetFirstEmptyId( self, d ):
		#TODO: Optimize this algorithm if needed.
		dID = 0
		while d.get(str(dID),None) is not None:
			dID += 1
		return dID

	def GetAccount(self, Aid):
		"""
		GetAcount( Aid ) -> Acount's entry (dictionary).
		Raises KeyError if Aid is not referencing an acount existing in the database.
		"""
		account = self.__accounts.get(str(Aid),None)
		if account is None:
			raise KeyError('Can\'t get acount. The provided Aid is not valid.')
		return account

	def GetAccountHistory(self, Aid):
		"""
		GetAcountHistory( Aid ) -> Sorted list of acount's history.
		Raises KeyError if Aid is not referencing an acount existing in the database.
		"""
		if self.__accounts.get(str(Aid),None) is None:
			raise KeyError('Can\'t get acount\'s history. The provided Aid is not valid.')
		return self.__updates.get( str(Aid), [] )

	def GetAccountIDs( self ):
		"""
		GetAcountIDs() -> Sorted list of acounts IDs.
		"""
		keys = []
		for key in self.__accounts.iterkeys():
			keys.append(int(key))
		keys.sort()
		return keys

	def SaveToFile(self, filename=DEFAULT_BACKUP_NAME):
		"""
		SaveToFile( [filename] )
		If filename is not given, the default backup name will be used.
		
		Saves a backup of the database to a file.
		"""
		#Not working yet
		return
		f = open( filename, 'w' )
		dump( self, f )
		f.close()

	def LoadFromFile(self, filename=DEFAULT_BACKUP_NAME):
		"""
		LoadFromFile( [filename] )
		If filename is not given, the default backup name will be used.
		
		Loads a backup of the database from a file.
		Every values are replaced by the ones being loaded from file.
		"""
		#Not working yet
		return
		f = open(filename,'r')
		temp = load( f )
		self.__clients, self.__accounts, self.__updates, stamps_temp = temp._replace()
		self._SetStampsData( stamps_temp )
		f.close()
		del temp

	def _replace( self ):
		return	self.__clients.copy(), self.__accounts.copy(), self.__updates.copy(), self._GetStampsData()

	def NewClient( self, name, address, birth, job, Cid=None ):
		"""
		NewClient( name, address, birth, job [,Cid] )->Cid
		If Cid is not given, a new one will be assigned.
		Raises KeyError if a given Cid is already in use.
		
		Creates a new record of a bank customer.
		Each record contains information that may give way to
		statistical purposes or simple data query.
		"""
		if Cid is not None:
			if self.__clients.get(str(Cid),None) is not None:
				raise KeyError('Can\'t create new bank\'s client. The Client ID is already in use.')
		else:
			Cid = self.__GetFirstEmptyId( self.__clients )
		
		self.__clients[ str(Cid) ] = { 	'Cname':str(name),
										'Caddress':address,
										'Cbirth':birth, 
										'Cjob':str(job) }
		self._NewEvent()
		return Cid

	def NewAccount( self, amount=0.00, newAid=None, Cid=None ):
		"""
		NewAccount( [amount] [,Aid] [,Cid] )->Aid
		If Aid is not given, a new one will be assigned.
		Raises ValueError if amount is negative.
		Raises KeyError if a given Cid is not valid.
		Raises KeyError if a given Aid is already in use.
		
		Creates a new record of a bank account.
		The accounts may or may not belong to the bank's clients who are
		recorded in the database.
		Any update on the account is recorded in history.
		"""
		if amount<0:
			raise ValueError('Can\'t create new acount. The opening amount is negative.')
		if Cid is not None:
			if self.__clients.get(str(Cid),None) is None:
				raise KeyError('Can\'t create new acount. The client ID provided does not exist.')
		if newAid is not None:
			if self.__accounts.get(str(newAid),None) is not None:
				raise KeyError('Can\'t create new acount. The acount ID is already in use.')
		else:
			newAid = self.__GetFirstEmptyId( self.__accounts )
		
		self.__accounts[ str(newAid) ] = {	'Aamount':float(amount),
											'AdateOfBegin':time(),
											'Aclient':Cid }
		self.__interestRate.ScheduleDeposit( newAid )
		self._NewEvent()
		if amount>0:
			self.UpdateAccount( newAid, 'credit', amount, 'Acount Opening' )
		return newAid

	def UpdateAccount( self, Aid, Type, amount, ufrom='unknown' ):
		"""
		UpdateAccount( Aid, type, amount [,ufrom] )->Aid
		Raises KeyError if Aid is not valid.
		Raises ValueError if type is not str.
		Raises ValueError if amount is negative.
		
		Adds a new event to the history of an update made to an account.
		"Type" can be:
			- DEBIT
			- CREDIT
		"Unknown" may be useful in indicating the receiver/container of transfers.
		"""
		if amount<0:
			raise ValueError('Can\'t register update. The amount is negative.')
		if not isinstance(Type,str):
			raise ValueError('Can\'t register update. The type is not str.')
		if self.__accounts.get(str(Aid),None) is None:
			raise KeyError('Can\'t register update. The account ID is not in use.')
		
		if self.__updates.get(str(Aid),None) is None:
			self.__updates[ str(Aid) ] = []
		history = self.__updates[str(Aid)]
		history.append( {	'Utype':Type.upper(),
							'Uamount':float(amount),
							'Ufrom':str(ufrom),
							'Cid':self.__accounts[str(Aid)]['Aclient'], 
							'Utime': ctime() } )
		self._NewEvent()
		
		return Aid

	def SetAccountOwner(self, Aid, Cid ):
		"""
		SetAccountOwner( Aid, Cid )->Aid
		Raises KeyError if Aid or Cid are not valid.
		
		Assigns ownership of a bank account to a bank customer.
		Both need to be registered in the database prior to this assignment.
		"""
		if self.__clients.get( str(Cid), None) is None:
			raise KeyError('The client ID provided does not exist.')
		if self.__acounts.get( str(Aid), None) is None:
			raise KeyError('The acount ID provided does not exist.')
		
		self.__accounts[str(Aid)]['Aclient']=Cid
		self._NewEvent()
		
		return Aid
	
	def Deposit(self, Aid, amount, ufrom='unknown'):
		"""
		Deposit( Aid, amount [,ufrom] )->Aid
		Raises KeyError if Aid is not valid.
		Raises ValueError if amount is negative.
		
		"Unknown" may be useful in indicating the receiver/container of transfers.
		This method is implemented in order to block concurrent access to the same account.
		"""
		account = self.__accounts.get( str(Aid), None )
		if account is None:
			raise KeyError('The acount id provided does not exist.')
		if amount < 0:
			raise ValueError( 'The deposit amount can\'t be negative.' )
		
		self.__globalLock.acquire( self.__accounts, Aid )
		
		account['Aamount'] += amount
		self.UpdateAccount( Aid, 'Credit', amount, ufrom )
		self.__globalLock.release( self.__accounts, Aid )
		
		return Aid
	
	def Withdrawal(self, Aid, amount, ufrom='unknown'):
		"""
		Withdrawal( Aid, amount [,ufrom] )->Aid
		Raises KeyError if Aid is not valid.
		Raises ValueError if amount makes the account to become without coverage.
		Raises ValueError if amount is negative.
		
		"Unknown" may be useful in indicating the receiver/container of transfers.
		"""
		account = self.__accounts.get( str(Aid), None)
		if account is None:
			raise KeyError('The acount id provided does not exist.')
		if amount < 0:
			raise ValueError( 'The withdrawal amount can\'t be negative.' )
		
		self.__globalLock.acquire( self.__accounts, Aid )
		
		result = account['Aamount'] - amount
		if result<0:
			self.__globalLock.release( self.__accounts, Aid )
			raise ValueError('The withdrawal amount is too high. The account would be without coverage.')
		else:
			account['Aamount'] = result
			self.UpdateAccount( Aid, 'Debit', amount, ufrom )
		self.__globalLock.release( self.__accounts, Aid )
		
		return Aid

	def DepositInterest( self, Aid, rate ):
		"""
		DepositInterest( Aid, rate ) -> Aid
		Raises KeyError if Aid is not valid.
		Raises ValueError if rate is not 0<rate<1
		"""
		account = self.__accounts.get( str(Aid), None )
		if account is None:
			raise KeyError('The acount id provided does not exist.')
		if rate>1 or rate<0:
			raise ValueError('Invalid amount for rate.')
		
		self.__globalLock.acquire( self.__accounts, Aid )
		
		amount = account['Aamount'] * rate
		account['Aamount'] += amount
		self.UpdateAccount( Aid, 'Credit', amount, 'Interest Amount' )
		
		self.__globalLock.release( self.__accounts, Aid )


#Example
if __name__=='__main__':
	CREATE_DB = True
	if CREATE_DB:
		db = DataBaseBank()
		
		#from pydoc import doc
		#doc( DataBaseObject )
		#print dir(db)
		
		print '---VectorStamps:',db.GetVectorStamps()
		a1 = db.NewAccount(amount=100)
		a2 = db.NewAccount(amount=200)
		print 'ID Primeira conta: ',a1
		print db.GetAccount(a1)
		print 'ID Segunda conta: ', a2
		print db.GetAccount(a2)
		
		print '\n---VectorStamps:',db.GetVectorStamps()
		db.Deposit( a1, 50 )
		print a1, db.GetAccount( a1 )
		print a2, db.GetAccount( db.Withdrawal( a2, 50 ) )
		
		print '\n---VectorStamps:',db.GetVectorStamps()
		print a1,db.GetAccountHistory( a1 )
		print a2,db.GetAccountHistory( a2 )
		
		db.SaveToFile()
		print '\nBackup completed.'

	else:
		db = DataBaseBank()
		db.LoadFromFile()
		print db.GetAccountIDs()
		for id in db.GetAccountIDs():
			print 'AcountID:',id,db.GetAccount(id)
		print '\nLoad from file completed.'
	
	
