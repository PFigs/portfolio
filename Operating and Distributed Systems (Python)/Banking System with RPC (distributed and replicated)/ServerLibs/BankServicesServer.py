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


import socket
from threading import Thread, Event
from time import time
from DataBase import DataBaseBank
from BankComServer import ServerToServerAPI
from BankComServer import ServerToClientAPI
from BankComServer import GetOtherBanks
from os import path

import Pyro.core
import Pyro.naming
from Pyro.errors import NamingError, PyroError


class ServerThread( Thread ):
	"""
	Provides services to the remote clients and servers
	"""

	def __init__( self, opts, ns, sapi, capi):
		Thread.__init__( self )
		
		self.__options = opts
		self.__ns = ns
		self.__sapi = sapi
		self.__capi = capi
		
		self.started = Event()
		self.started.clear()
		self.start()

	def run(self):
		if Pyro.util.supports_multithreading():
			Pyro.config.PYRO_MULTITHREADED = 1
		Pyro.core.initServer()
		host = self.__options['serverHostname']
		port = self.__options['serverPort']
		phost = self.__options['publishHost']
		name = self.__options['name']
		self.__serverDaemon = Pyro.core.Daemon('PYRO', host, port, 0, phost )
		self.__serverDaemon.useNameServer( self.__ns )
		Pyro.config.PYRO_NS_DEFAULTGROUP = self.__options['group']
		
		try:
			self.__ns.unregister( name )
		except:
			pass
		self.__serverDaemon.connect( self.__capi, name )
		try:
			self.__ns.unregister( 'Private.' + name)
			##set recovery flag
		except:
			pass
		self.__serverDaemon.connect( self.__sapi, 'Private.'+name )
		self.__ns.setMeta( 'Private.'+ name, time() )
		
		self.started.set()
		self.__serverDaemon.requestLoop()

	def unpublish( self ):
		name = self.__options['name']
		self.__ns.unregister( name )
		self.__ns.unregister( 'Private.' + name )

	def close(self):
		print 'The server is shutting down...'
		self.__capi.daemon.shutdown
		self.__sapi.daemon.shutdown
		self.__serverDaemon.shutdown()
		self.__serverDaemon.shutdown()
		self.join()
		
		return self.__sapi.isCoordinator()


class Services:

	def __init__( self, options ):
		self.__options = options	#dict
		self.__serverThread = None	#threading.Thread
		self.__dataBase = None		#ServerLibs.DataBase.DataBaseBank
		self.__ns = None			#Pyro.Core.ObjBase

	def __namingService(self):
		Pyro.config.PYRO_NS_URIFILE = None
		Pyro.config.PYRO_NS_DEFAULTGROUP = self.__options['group']
		Pyro.config.PYRO_NS_HOSTNAME = self.__options['nsHostname']
		Pyro.config.PYRO_NS_PORT = self.__options['nsPort']
		
		print 'Searching Naming Service...'
		try:
			ns = Pyro.naming.NameServerLocator().getNS()
		except PyroError, error:
			return 'Error: '+str(error)
		print 'Naming Service found at:',ns.URI.address
		
		def guarantee( func, arg ):
			try:
				rsp = func( arg )
			except:
				return None
			return rsp
		
		#Guarantee minimum conditions at the Name Server
		guarantee( ns.createGroup, self.__options['group'] )
		guarantee( ns.createGroup, self.__options['group']+'.Private' )
		
		return ns

	def __getIP(self):
		s = socket.socket( socket.AF_INET, socket.SOCK_DGRAM )
		s.connect( (self.__ns.URI.address, self.__ns.URI.port) )
		ip = s.getsockname()[0]
		s.shutdown( socket.SHUT_RDWR )
		return str(ip)

	def __validateInput( self ):
		if self.__options['serverHostname'] == self.__options['nsHostname']:
			if self.__options['serverPort'] == self.__options['nsPort']:
				return 'Error: The server\'s port can\'t be the same of the NameServer.'
		
		if self.__options[ 'group' ][0] is not ':':
			self.__options[ 'group' ] = ':'+self.__options[ 'group' ]
		
		if self.__options['serverHostname'] == '127.0.0.1':
			try:
				addr = self.__getIP()
			except:
				return 'Error: Unable to get the IP address assigned to this machine.'
			self.__options['serverHostname'] = addr
		
		if self.__options['publishHost'] == '127.0.0.1':
			self.__options['publishHost'] = self.__options['serverHostname']
		
		print '\''+str(self.__options['name'])+'\' will try to run at:', self.__options['serverHostname']
		print '\''+str(self.__options['name'])+'\' will be published with:', self.__options['publishHost']


	def __findCoordinator(self):
		banks = GetOtherBanks( self.__ns, self.__options['group'], self.__options['name'] )
		if isinstance( banks, str ):
			return banks
		if banks:
			coordinator = None
			for bank in banks:
				try:
					proxy = bank['Proxy']
					coordinator = proxy.getCoordinator()
					if coordinator is None:
						coordinator = bank['URI']
						break
					else:
						try:
							proxy = Pyro.core.getProxyForURI( coordinator )
							break
						except:
							continue
				except:
					continue
		else:
			coordinator = None
			proxy = None

		return coordinator,proxy

	def __syncNetworkState( self, log, Epoch, coordinator, proxy ):
		'''
		Allows the server to sync with the network
		'''
		if not coordinator:
			##Must rollback to my known place
			coordinator = None
			lastElected = 1
			if log:
				#If starting from epoch 0, I already have account info
				if not Epoch == 0:
					for op in log['CheckPoint']:
						#UpdateAccount( self, Aid, timeOfBegin, amount, version, state
						self.__dataBase.UpdateAccount(op[0],op[4],op[1],op[2],op[3],False)
						
				for op in log['Operations']:
					#SimpleUpdate( self, Aid, amount, version, state
					self.__dataBase.SimpleUpdate(op[1],int(op[2]),float(op[4]),int(op[5]),op[6],False)
		else:
			try:
				lastop=0
				if log:
					for line in log['Operations']:
						lastop = int(line[0])
				lastElected = proxy.getElectionID()
				sync = proxy.sync(Epoch,self.__dataBase.vars['OpNum'],self.__options['name'], lastop)
			except:
				return 'Error: Failed to get initialization data from coordinator.'
			if sync[0]:
				for update in sync[0]:
					#SimpleUpdate( self, Aid, amount, version, state
					self.__dataBase.log.raw('$$\t'+'Sync\t'+str(self.__dataBase.vars['OpNum'])+'\t'+'Commit\n')
					if not sync[1]:
						#def SimpleUpdate( self, type, Aid, amount, version, state ):
						self.__dataBase.SimpleUpdate(update[0],update[1],update[2],update[3],update[4])
					else:
						self.__dataBase.UpdateAccount( update[0], update[1], update[2], update[3], update[4])

		return { 'coordinator':coordinator, 'lastElected':lastElected, 'lastAttempt': 0 }

	def getDatabase( self ):
		if self.__dataBase is None:
			return 'Error: a new DataBase needs to be created first.'
		return self.__dataBase

	def startServer( self ):
		self.__ns = self.__namingService()
		if isinstance( self.__ns, str ):
			return self.__ns
		
		error = self.__validateInput()
		if isinstance( error, str ):
			return error
		
		self.__dataBase = DataBaseBank(self.__options['name']+'/')

		log = None
		location = self.__findCoordinator()
		#Decides wether to read the init file (first run) or the first checkpoint
		if path.exists(self.__dataBase.vars['LogPath'] + '0' + '.log'):
			if self.__options['verbose']:
				print 'Getting info from checkpoint 0'
			log = self.__dataBase.RollBack(0)
			error = self.__dataBase.Initialize( log['CheckPoint'] )
			while True:
				if path.exists(self.__dataBase.vars['LogPath'] + str(self.__dataBase.vars['LogNum']) + '.log'):
					try:
						if self.__options['verbose']:
							print 'RollBacking!'
						log = self.__dataBase.RollBack(self.__dataBase.vars['LogNum'])
						break
					except:
						self.__dataBase.vars['LogNum']-=1
		else:
			if self.__options['verbose']:
				print 'Getting info from init file'
			error = self.__dataBase.Initialize( self.__options['file'] )
			#Update account creation time if not coordinator
			if location[0]:
				for BTime in location[1].getInterestTime():
					self.__dataBase.TimeUpdate(BTime[0],BTime[1])
			self.__dataBase.CheckPoint(False)
			if self.__options['verbose']:
				print 'Checkpoint done!'

		if isinstance( error, str ):
			return error
		##Sync last checkpoint with network present status
		network = self.__syncNetworkState(log,self.__dataBase.vars['LogNum'], location[0],location[1])
		if isinstance( network, str ):
			return network

		self.__dataBase.ScheduleInterest()

		serverAPI = ServerToServerAPI( self.__ns,
										network['coordinator'],
										network['lastElected'],
										network['lastAttempt'],
										self.__dataBase,
										self.__options)
		
		clientAPI = ServerToClientAPI( serverAPI, self.__options['verbose'] )

		self.__serverThread = ServerThread(	self.__options,
										self.__ns,
										serverAPI,
										clientAPI )
		self.__serverThread.started.wait()
		
		if self.__options['verbose']:
			print '---\nStarting an election. ID:', network['lastElected']
		serverAPI.election( network['lastElected'] )

	def close( self ):
		isCoordinator = False
		if isinstance( self.__serverThread, ServerThread ):
			self.__serverThread.unpublish()
			isCoordinator = self.__serverThread.close()
			
			if self.__ns and isCoordinator:
				banks = GetOtherBanks( self.__ns, self.__options['group'], self.__options['name'] )
				if isinstance( banks, str ):
					print banks
				elif banks:
					print'Leaving Network...'
					try:
						proxy = Pyro.core.getProxyForURI( banks[0]['URI'] )
					except:
						return 'Error: Failed to process receive server\'s proxy.'
					try:
						electionId = proxy.getElectionID()
						proxy._setOneway("election")
						if self.__options['verbose']:
							print 'Starting an election. ID:',electionId
						proxy.election( electionId )
					except:
						return 'Error: Failed to start a new election on the other servers.'
		
		if isinstance( self.__dataBase, DataBaseBank ):
			self.__dataBase.close()


