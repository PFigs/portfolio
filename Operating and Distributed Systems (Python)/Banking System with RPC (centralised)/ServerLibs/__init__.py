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


from BankServicesServer import Services
from signal import pause
from threading import enumerate, currentThread, activeCount

class Server:
	"""
	Definition of the server class.
	This class sets the behaviour for the server.
	"""
	def __init__( self, options ):
		"""
		Starts pyro server and request loop
		"""
		self.__name = options['name']
		self.__verbose = options['verbose']
		self.__services = Services( options )

	def RunInterface( self ):
		"""
		Enter the service loop.
		"""
		self.__api = self.__services.startServer()
		if isinstance( self.__api, str):
			self.__services.Close()
			return self.__api
		
		print 'Server %s is open for business'%self.__name
		if self.__verbose:
			print '< press CTRL-C to shutdown >'
			try:
				pause()
			except:
				print 
				self.exit()
		else:
			choices = { 	'0': self.exit,
							'1': self.listAllAccounts,
							'2': self.viewAccountHistory,
							'7': self.about }
			while True:
				print "\n---- SOD - Bank Managment ----"
				print "1: list all accounts"
				print "2: view account history"
				print "7: about"
				print "0: exit\n"
				
				while True:
					try:
						choice = input("Choice: ")
					except:
						print 'Error: The choice is not recognizable.'
						continue
					func = choices.get( str(choice), None )
					if func is None:
						print 'Error: The choice is not recognizable.'
					else:
						break
				if func() is -1:
					break
		return 'See you later.'

	def listAllAccounts( self ):
		print self.__api.listAccounts()

	def viewAccountHistory( self ):
		try:
			Aid = input("Account number: ")
			rsp = self.__api.getAccountHistory( int(Aid) )
		except KeyError, error:
			print error
			return
		except:
			print 'Error: invalid.'
			return
		print rsp

	def about( self ):
		print  " ___________________________________________"
		print "( Distributed and Operative Systems Project )"
		print "( Bank Managment.                           )"
		print "( Developed by:                             )"
		print "( Martim Camacho                            )"
		print "( Filipe Funenga                            )"
		print "( Pedro Silva (58035)                       )"
		print "( @ IST - 1 Semestre - 10/11                )"
		print " -------------------------------------------"
		print "  o\n    o"
		print "        .--.\n       |o_o |"
		print "       |:_/ | \n      //   \\ \\ "
		print "     (|     | )\n    /'\\_   _/`\\ "
		print "    \\___)=(___/"

	def exit( self ):
		self.__services.Close()
		print 'The server is closed.'
		cThread = currentThread()
		for thread in enumerate():
			if thread is not cThread:
				if activeCount() is 1:
					break
				print 'Closing... ('+str(activeCount()-1)+')'
				thread.join()
		return -1

## MUST daemon.shutdown() to force thread death
