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
from threading import enumerate, currentThread, activeCount


class Server:

	"""
	Definition of the server class.
	This class sets the behaviour for the server.
	"""

	def __init__( self, options ):
		self.__name = options['name']
		self.__verbose = options['verbose']
		self.__services = Services( options )

	def runInterface( self ):
		rsp = self.__services.startServer()
		if isinstance( rsp, str):
			self.exit()
			return rsp
		
		if self.__verbose:
			from signal import pause
			print '< press CTRL-C to shutdown >'
			try:
				pause()
			except:
				print 
				self.exit()
		else:
			choices = { 	'0': self.exit,
							'1': self.listAllAccounts,
							'2': self.about }
			while True:
				print "\n---- Bank %s ----"%self.__name
				print "0: exit"
				print "1: list all accounts(locally)"
				print "2: about\n"
				
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

	def exit( self ):
		self.__services.close()
		
		cThread = currentThread()
		for thread in enumerate():
			if thread is not cThread:
				if activeCount() is 1:
					break
				print 'Closing... ('+str(activeCount()-1)+')'
				thread.join()
		
		return -1

	def listAllAccounts( self ):
		"""
		Print all accounts.
		"""
		dataBase = self.__services.getDatabase()
		Aliststr = 'LIST OF ACCOUNTS\n'
		counter = 0
		for Aid in dataBase.GetAccountIDs():
			account = dataBase.GetAccount( Aid )
			Aliststr += 'Account: ' + str( Aid ) + '  Balance: ' + str( format(account['Aamount'], '.2f') ) + '\n'
			counter += 1
		if counter == 0:
			counter = 'No'
		else:
			counter = str(counter)
		print Aliststr + '--- '+counter+' accounts.'

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
