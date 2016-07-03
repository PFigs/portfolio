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
Implements the terminal client of the bank server.
Pyro developed by Irmen.
"""

from BankServicesClient import Services
from BankScripter import Scripter
from signal import pause
from threading import Thread, Event, enumerate, currentThread, activeCount
import Pyro.naming, Pyro.core
from time import sleep

class Client( object ):
	"""
	Class that defines the client behaviour
	"""

	def __init__( self, options ):
		self.__options = options
		self.__prompt = "command :> "
		self.__choices = { 	'0': self.exit,
							'1': self.getHelp,
							'2': self.about,
							'3': self.deposit,
							'4': self.withdraw,
							'5': self.transfer,
							'6': self.viewBalance,
							'9': self.test
							}
		self.__services = None

	def Run( self ):
		"""
		Client main loop.
		It can only continue if a name server is found, otherwise the client is shutdown.
		The scheduler and command options are initialized.
		"""
		
		self.__services = Services(	self.__options['nhostname'],
									self.__options['nport'],
									self.__options['group'], self.__options )
		
		error = self.__services.FindNameServer()
		if error is not None:
			return error
		self.__bank = self.__services.GetClosestServer()
		if isinstance(self.__bank,str):
			return self.__bank

		if self.__options['verbose']:
			print '< Verbose is on >' 
		if self.__options['benchmark']:
			print '< Benchmark is on >'
		
		#Initializes the scheduler with the contents present in the init file
		self.__scheduler = Scripter( self.__bank, self.__options['verbose'], self.__options['benchmark'] )
		for line in self.__options['file']:
			self.__scheduler.addtoQueue(line)
		self.__scheduler.clearNewCommand()
		self.__scheduler.clearWake()
		self.__scheduler.start()

		#If verbose, it deactivates the user interface
		if self.__options['verbose']:
			try:
				print '< press CTRL-C to shutdown >'
				pause()
			except:
				self.exit( )
		else:
			#Prints the prompt and gets user input, while run is True
			self.getHelp( )
			run = True
			while run:
				cmd = self.promptUser( self.__prompt )
				run = self.sendCommand( cmd )
			
		return 'See you soon!'

	def __inputAid( self, movString ):
		while True:
			try:
				inp = raw_input( movString+" ID: " )
			except:
				print 'Error: The account id is not recognizable.'
				continue
			if inp == 'x':
				return None
			try:
				Aid = int(inp)
				if Aid < 0:
					print 'Error: The account id is not valid'
					continue
				break
			except:
				print 'Error: The account id is not recognizable.'
				continue
		return Aid

	def __inputAmount( self, movString ):
		while True:
			try:
				inp = raw_input("Amount to "+movString.lower()+": ")
			except:
				print 'Error: The amount is not recognizable.'
				continue
			if inp == 'x':
				return None
			try:
				amount = float(inp)
				if amount <= 0:
					print 'Error: invalid amount.'
					continue
				break
			except:
				print 'Error: The amount is not recognizable.'
				continue
		return amount

	def __input( self, actions ):
		result = []
		for action in actions:
			rsp = action[0]( action[1] )
			if rsp is None:
				return None
			result.append( rsp )
		return result
		
	def __remotecall( self, name, args ):
		delay = 1
		run = True
		
		while run:
			try:
				if name == 'deposit':
					print self.__bank.deposit( *args )
				elif name == 'withdraw':
					print self.__bank.withdraw( *args )
				elif name == 'transfer':
					print self.__bank.transfer( *args )
				elif name == 'viewBalance':
					print self.__bank.viewBalance( args )
				run = False
				self.__bank._release()
			except Pyro.errors.ProtocolError:
				newbank = self.__services.GetClosestServer()
				if isinstance(newbank,str):
					print 'Error: connection to server lost.'
					print 'Retrying in', delay,'second(s). Press <CTRL+C> to shutdown.'
					sleep( delay )
					if delay < 20:
						delay = delay * 2
					else:
						delay = 20
				else:
					self.__bank=newbank

	def deposit( self ):
		"""
		Deposits an amount at the given account
		"""
		print "Deposit"
		
		actions = [	( self.__inputAid, 'Account' ),
					( self.__inputAmount, 'deposit' ) ]
		values = self.__input( actions )
		if values is None:
			return True
		else:
			Aid, amount = values[0], values[1]
		try:
			self.__remotecall( 'deposit', (Aid, amount))
		except KeyboardInterrupt:
			print '\nExiting'
			return self.exit()

		return True

	def withdraw( self ):
		"""
		Allows to withdraw an amount at the given account
		"""
		print "Withdraw"
		
		actions = [	( self.__inputAid, 'Account' ),
					( self.__inputAmount, 'withdraw' ) ]
		values = self.__input( actions )
		if values is None:
			return True
		else:
			Aid, amount = values[0], values[1]

		try:
			self.__remotecall( 'withdraw', (Aid, amount))
		except KeyboardInterrupt:
			print '\nExiting'
			return self.exit()
	
		return True

	def transfer( self ):
		"""
		Transfers money from and to an account
		"""
		print "Transfer:"
		
		actions = [	( self.__inputAmount, 'transfer' ),
					( self.__inputAid, 'From account' ),
					( self.__inputAid, 'To account' ) ]
		values = self.__input( actions )
		if values is None:
			return True
		else:
			amount, fromAid, toAid = values[0], values[1], values[2]
		
		if fromAid == toAid:
			print 'Error: the accounts indicated are the same.'
			return True
		
		try:
			self.__remotecall( 'withdraw', ( fromAid, toAid, amount ))
		except KeyboardInterrupt:
			print '\nExiting'
			return self.exit()
		
		return True

	def viewBalance( self ):
		"""
		Obtains the balance of an account
		"""
		print "Check Account Balance:"
		
		Aid = self.__inputAid( 'Account' )
		if Aid is None:
			return True
		
		try:
			self.__remotecall( 'viewBalance', (Aid) )
		except KeyboardInterrupt:
			print '\nExiting'
			return self.exit()
			
		return True
		
	def test( self ):
		"""
		Obtains the balance of an account
		"""
		print "Test function"

		#try:
		print self.__bank.test()
		#except:
		print 'Error: unable to process request with server'

		return True

	def about( self ):
		"""
		Outputs information about the authors of the program
		"""
		print  " ___________________________________________"
		print "( Distributed and Operative Systems Project )"
		print "( Bank Managment.                           )"
		print "( Developed by:                             )"
		print "( Martim Camacho(56755)                     )"
		print "( Filipe Funenga(57977)                     )"
		print "( Pedro Silva (58035)                       )"
		print "( @ IST - 1 Semestre - 10/11                )"
		print " -------------------------------------------"
		print "  o\n    o"
		print "        .--.\n       |o_o |"
		print "       |:_/ | \n      //   \\ \\ "
		print "     (|     | )\n    /'\\_   _/`\\ "
		print "    \\___)=(___/"
		return True

	def getHelp( self ):
		"""
		Outputs the allowed commands
		"""
		print "\n---- SOD - Bank Managment ----"
		print "List of known commands"
		print "0: exit"
		print "1: menu"
		print "2: about"
		print "3: deposit money"
		print "4: withdraw money"
		print "5: transfer money"
		print "6: view balance\n"
		#print "7: view movements\n"
		return True

	def promptUser( self, prompt ):
		"""
		Obtains input from the user
		"""
		while True:
			try:
				choice = input(prompt)
			except SyntaxError:
				continue
			except:
				print 'I\'m sorry, you entered an unknown command.\nPress 1 for help.'
				continue
			func = self.__choices.get( str(choice), None )
			if func is None:
				print 'I\'m sorry, you entered an unknown command.\nPress 1 for help.'
				continue
			else:
				break
		return func
	
	def sendCommand( self, cmd ):
		"""
		Executes the command
		"""
		return cmd()

	def exit( self ):
		"""
		Allows the user to terminate the client program
		"""
		
		print 'Closing connection to server...'
		if self.__scheduler is not None:
			self.__scheduler.setWake()
		else:
			print 'Scheduler does not exists.'
		
		for thread in enumerate():
			if thread is not currentThread():
				if activeCount() is 1:
					break
				#print 'Closing... ('+str(activeCount()-1)+')'
				thread.join()
		return False
