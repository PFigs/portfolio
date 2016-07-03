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


class Services():
	"""
	Provides lookup features for the client.
	Searches for a nameserver and registered members in the given group.
	"""

	def __init__(self, nhostname, nport, group ):
		Pyro.config.PYRO_NS_HOSTNAME = nhostname
		Pyro.config.PYRO_NS_PORT = nport
		Pyro.config.PYRO_NS_DEFAULTGROUP = group
		self.__group = group
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
			return 'Error: '+str(error)
		print 'NameServer has been found at', self.__ns.URI.address

	def __SelectCloser( self, banks ):
		# TODO: Update this method for the second part
		# closer="is the most similar ip address"
		return banks[0][0]

	def GetClosestServer( self ):
		if self.__ns is None:
			return 'Error: NameServer has to be found first.', None
		try:
			groupList = self.__ns.list( self.__group )
		except NamingError, error:
			errorMsg='Error: '
			for e in error:
				errorMsg += e+' '
			return errorMsg, None
		try:
			banks = []
			uriAll = self.__ns.flatlist()
			for name in groupList:
				fullname = self.__ns.fullName( name[0] )
				uri = None
				for flaturi in uriAll:
					if fullname == flaturi[0]:
						uri = flaturi[1]
						break
				banks.append( ( name[0], uri.address ) )
		except:
			return 'A problem ocurred while retrieving banks list.', None
		if not banks:
			return 'There are no banks to do business with!', None
		
		bank = self.__SelectCloser( banks )
		try:
			URI = self.__ns.resolve( bank )
		except Pyro.core.PyroError,x:
			return 'Bank\'s name could not be resolved: '+str(x), None
		
		return None, Pyro.core.getProxyForURI( URI )
