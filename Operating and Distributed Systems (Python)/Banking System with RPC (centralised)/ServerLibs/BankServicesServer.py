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

from threading import Thread
from DataBase import DataBaseBank
from BankComServer import ServerAPI

import Pyro.core
import Pyro.naming
from Pyro.errors import NamingError, PyroError


class Services:
	"""
	Pyro developed by Irmen.
	"""

	class Server( Thread ):
		def __init__( self, host, port, phost, ns, api, name ):
			Thread.__init__( self )
			self.__api = api
			Pyro.config.PYRO_MULTITHREADED = 1
			self.__serverDaemon = Pyro.core.Daemon('PYRO', host, port, 0, phost )
			self.__serverDaemon.useNameServer( ns )
			self.__serverDaemon.connect( api, name )
		
		def run(self):
			self.__serverDaemon.requestLoop()
		
		def shutdown(self):
			try:
				self.__serverDaemon.disconnect( self.__api )
			except:
				print 'Error while disconnecting api from NameServer.'
			self.__serverDaemon.shutdown(True)
			print 'The server is shutting down...'
			self.join()

	def __init__(self, options):
		self.__options = options
		self.__serverThread = None
		self.__ns = None
		self.__dataBase = None

	def Close( self ):
		if self.__serverThread:
			self.__serverThread.shutdown()
		self.__nss.shutdown()
		self.__dataBase.Close()

	def startServer( self ):
		Pyro.core.initServer()
		#NameServer
		self.__ns, self.__nss = self.__createNamingService()
		if isinstance( self.__ns, str ):
			return self.__ns
		
		#DB & API
		self.__dataBase = DataBaseBank()
		self.__serverAPI = ServerAPI( self.__dataBase, self.__options['verbose'] )
		print 
		for line in self.__options['file']:
			print 'Init file:',self.__serverAPI.createAccount( line[1], line[0] )
		
		#Server
		try:
			self.__serverThread = Services.Server(	self.__options['serverHostname'],
													self.__options['serverPort'],
													self.__options['publishHost'],
													self.__ns,
													self.__serverAPI,
													self.__options['name'] )
			self.__serverThread.start()
		except:
			return 'Error ocurred while creating server.'
		
		return self.__serverAPI

	def __createNamingService(self):
		Pyro.config.PYRO_NS_DEFAULTGROUP = self.__options['group']
		Pyro.config.PYRO_NS_URIFILE = None
		Pyro.config.PYRO_NS_HOSTNAME = self.__options['nsHostname']
		Pyro.config.PYRO_NS_PORT = self.__options['nsPort']
		
		#Rule: If Naming Service doens't already exists, then a new one is created.
		
		nameServerLocator = Pyro.naming.NameServerLocator()
		try:
			print 'Searching Naming Service...'
			ns = nameServerLocator.getNS()
		except PyroError:
			nss = Pyro.naming.NameServerStarter()
			nsHost = self.__options['nsHostname']
			nsPort = self.__options['nsPort']
			nssThread = Thread( target=nss.start, args=( nsHost, nsPort ) )
			nssThread.setDaemon( True )
			nssThread.start()
			print 'Naming Service is down, lauching a new one...'
			if nss.waitUntilStarted():
				ns = nameServerLocator.getNS()
			else:
				return 'Naming Server was not created.'
		
		#Make sure our namespace group exists in the name service.
		try:
			ns.createGroup( self.__options['group'] )
		except NamingError:
			pass
		#Make sure there is no object implementation registered.
		try:
			ns.unregister( self.__options['name'] )
		except NamingError:
			pass
		
		return ns, nss

	def __get_my_ip_address():
		import urllib
		whatismyip = 'http://www.whatismyip.com/automation/n09230945.asp'
		return urllib.urlopen(whatismyip).readlines()[0]
