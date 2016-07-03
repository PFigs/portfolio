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

from time import ctime
from Pyro.core import ObjBase


class ServerAPI( ObjBase ):
	"""
	Contains the api with the bank server.
	"""
	def __init__( self, db, verbose ):
		ObjBase.__init__(self)
		self.__db = db
		self.__verbose = verbose

	def createAccount( self, amount=0, Aid=None ):
		try:
			Aid = self.__db.NewAccount( amount, Aid )
		except KeyError, error:
			return error
		except ValueError,error:
			return error
		rsp = 'Created account ' + str(Aid) + ' with ' + str(amount) + '€'
		if self.__verbose:
			print rsp
		return rsp

	def listAccounts(self):
		Aliststr='LIST OF ACCOUNTS\n'
		accountsList = self.__db.GetAccountIDs()
		if accountsList:
			counter = 0
			for Aid in accountsList:
				account = self.__db.GetAccount(Aid)
				Aliststr += 'Account: ' + str( Aid ) + '  ' + 'Balance: ' + str( format(account['Aamount'], '.2f') ) + '\n'
				counter += 1
			Aliststr += '--- '+str(counter)+' accounts.'
		else:
			Aliststr += '--- No accounts.'
		if self.__verbose:
			print 'Listing accounts.'
		return Aliststr

	def viewBalance(self, Aid):
		try:
			account = self.__db.GetAccount( Aid )
		except KeyError, error:
			return error
		if self.__verbose:
			print 'Checking balance.'
		return '%.2f'%account['Aamount']

	def getAccountHistory(self, Aid):
		try:
			account = self.__db.GetAccountHistory( Aid )
		except KeyError, error:
			return error
		except ValueError, error:
			return error
		Amovements = 'MOVEMENTS HISTORY --- ACCOUNT: ' + str(Aid) + '\n'
		i=0
		for entry in account:
			i+=1
			iteration = str(i)+'. '
			date = entry['Utime']+' '
			tipo = entry['Utype']+' '
			amount = str( format(entry['Uamount'],'.2f') )+' '
			ufrom = entry['Ufrom']+'\n'
			Amovements += iteration+'Date: '+date+'Type: '+tipo+'Amount: '+amount+'From: '+ufrom
		if self.__verbose:
			print 'Checking account history.'
		return Amovements

	def deposit(self, Aid, amount, source='unknown'):
		try:
			Aid = self.__db.Deposit( Aid, amount, source )
		except KeyError,error:
			return error
		except ValueError, error:
			return error
		rsp = 'Deposited ' + str(amount) + '€ in account ' + str(Aid)
		if self.__verbose:
			print rsp
		return rsp

	def withdraw(self, Aid, amount, source='unknown' ):
		try:
			Aid = self.__db.Withdrawal( Aid, amount, source )
		except KeyError, error:
			return error
		except ValueError, error:
			return error
		rsp = 'Withdrew ' + str(amount) + '€ in account ' + str(Aid)
		if self.__verbose:
			print rsp
		return rsp

	def transfer( self, fromAid, toAid, amount ):
		try:
			fromAid = self.__db.Withdrawal( fromAid, amount, 'Transfer to '+str(toAid) )
		except KeyError, error:
			return error
		except ValueError, error:
			return error
		
		try:
			toAid = self.__db.Deposit( toAid, amount, 'Transfer from '+str(fromAid) )
		except KeyError,error:
			return error
		except ValueError, error:
			return error
		
		rsp = 'Transfered '+ str(amount) + '€ from ' + str( fromAid ) + ' to ' + str( toAid )
		if self.__verbose:
			print rsp
		return rsp

	#------------------------------------------------------

	def deleteAccount(self, Aid):
		return 'not yet implemented'

	def payService(self, serviceID, amount, UID, PIN):
		return 'not yet implemented'

	def createCard(self, UID, PIN, limitCash=5000):
		return 'not yet implemented'

	def echo( self, echo):
		return echo
