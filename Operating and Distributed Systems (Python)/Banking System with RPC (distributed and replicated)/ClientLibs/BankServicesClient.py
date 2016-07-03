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


#http://stackoverflow.com/questions/58294/how-do-i-get-the-external-ip-of-a-socket-in-python
import Pyro.naming
import Pyro.core
from Pyro.errors import PyroError, NamingError
from threading import Thread
import socket

class Services:
	"""
	Provides lookup features for the client.
	Searches for a nameserver and registered members in the given group.
	"""

	def __init__(self, nhostname, nport, group, options ):
		self.__options = options
		Pyro.config.PYRO_NS_HOSTNAME = self.__options['nhostname']
		Pyro.config.PYRO_NS_PORT = self.__options['nport']
		Pyro.config.PYRO_NS_DEFAULTGROUP = self.__options['group']
		self.__ns = None

	def FindNameServer( self ):
		"""
		Tries to find a nameserver and retrieve the list of registered members on the client group.
		In case of success this list is return. Otherwise an exception is raised.
		"""
		
		Pyro.core.initClient()
		nsLocator = Pyro.naming.NameServerLocator()
		print 'Searching Naming Service..'
		try:
			self.__ns = nsLocator.getNS()
		except NamingError, error:
			return 'Error: ' + str(error)
		print 'NameServer has been found at', self.__ns.URI.address
		

	def __SelectCloser( self, banks ):
		"""
		Selects the server with the closest IP to the client
		"""
		mydecip = self.__strdecIP( self.__getIP() )
		bkdecip = mydecip - self.__strdecIP(banks[0]['URI'].address)
		if bkdecip < 0:
			bkdecip *=-1
		bank = None
		for agency in banks:
			aux = mydecip - self.__strdecIP(agency['URI'].address)
			if aux < 0:
				aux*=-1
			if aux <= bkdecip:
				bank = agency
				bkdecip = aux
		return bank

	def GetClosestServer( self ):
		"""
		Obtains the closest server based on the similarity of IPs
		"""
		if self.__ns is None:
			return 'Error: NameServer has to be found first.'
		try:
			banks = []
			uriAll = self.__ns.flatlist()
			for (fullname,value) in uriAll:
				for each in [fullname.split('.')]:
					if each[0] == self.__options['group'] and each[1] != 'Private':
						name = each[1]
						banks.append({'Name': name,'URI': value})
		except:
			return 'A problem ocurred while retrieving banks list.'
		if not banks:
			return 'There are no banks to do business with!'
		if self.__options['verbose']:
			print 'Obtaining closest server'
		bank = self.__SelectCloser( banks )

		if bank:
			print 'Connecting to \'' + bank['Name']+'\' at ',bank['URI'].address
		else:
			print 'No banks found'
		try:
			proxy = None
			proxy = Pyro.core.getProxyForURI( bank['URI'] )
			print 'Connection successful'
		except:
			return 'Can not connect to remote server'
			
		return proxy
		
	def __getIP(self):
		s = socket.socket( socket.AF_INET, socket.SOCK_DGRAM )
		s.connect( (self.__ns.URI.address, self.__ns.URI.port) )
		ip = s.getsockname()[0]
		s.shutdown( socket.SHUT_RDWR )
		print 'Running at:', ip
		return ip
	
	def __strdecIP(self, ip):
		fields = ip.split('.')
		return int(fields[0])*(256**3)+int(fields[1])*(256**2)+int(fields[2])*(256)+int(fields[3])
