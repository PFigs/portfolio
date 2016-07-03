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
						'3': self.createAccount,
						'4': self.deposit,
						'5': self.withdraw,
						'6': self.transfer,
						'7': self.viewBalance,
						'8': self.getAccountHistory,
						'9': self.listAllAccounts,
						'10': self.scheduleDeposit,
						'11': self.scheduleWithdraw,
						'12': self.scheduleTransfer,
						'13': self.viewSchedule
						}

	def Run( self ):
		"""
		Client main loop.
		It can only continue if a name server is found, otherwise the client is shutdown.
		The scheduler and command options are initialized.
		"""
		
		services = Services(	self.__options['nhostname'],
								self.__options['nport'],
								self.__options['group'] )
		
		error = services.FindNameServer()
		if error is not None:
			return error
		error, self.__bank = services.GetClosestServer()
		if error is not None:
			return self.__bank

		if self.__options['verbose']:
			print '< Verbose is on >' 
		if self.__options['benchmark']:
			print '< Benchmark is on >'
		
		#Initializes the scheduler with the contents present in the init file
		self.__scheduler = Scripter( self.__bank, self.__options['verbose'] ,self.__options['benchmark'] )
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
				self.exit( self.__bank )
		else:
			#Prints the prompt and gets user input, while run is True
			self.getHelp( self.__bank )
			run = True
			while run:
				cmd = self.promptUser( self.__prompt )
				run = self.sendCommand( cmd, self.__bank )
			
		return 'See you soon!'

	def createAccount( self, bank ):
		"""
		Creates an account with a starting amount at the given bank
		"""
		print "Create Account:"
		amount = None
		while amount is None:
			try:
				amount = float(input("Initial amount: "))
			except:
				print 'Error: The amount is not recognizable.'
		if amount < 0:
			print 'Values should be greater than zero'
		else:
			print bank.createAccount( amount, None )
		return True

	def deposit( self, bank ):
		"""
		Deposits an amount at the given account
		"""
		print "Deposit:"
		Aid = None
		while Aid is None:
			try:
				Aid = int(input("Account ID: "))
			except:
				print 'Error: The account id is not recognizable.'
		amount = None
		while amount is None:
			try:
				amount = float(input("Amount to deposit: "))
			except:
				print 'Error: The amount is not recognizable.'
		print bank.deposit( Aid, amount )
		return True

	def withdraw( self, bank ):
		"""
		Allows to withdraw an amount at the given account
		"""
		print "Withdraw:"
		Aid = None
		while Aid is None:
			try:
				Aid = int(input("Account ID: "))
			except:
				print 'Error: The account id is not recognizable.'
		amount = None
		while amount is None:
			try:
				amount = float(input("Amount to withdraw: "))
			except:
				print 'Error: The amount is not recognizable.'
		print bank.withdraw(Aid, amount)
		return True

	def transfer( self, bank ):
		"""
		Transfers money from and to an account
		"""
		print "Transfer:"
		amount = None
		while amount is None:
			try:
				amount = float(input("Amount to transfer: "))
			except:
				print 'Error: The amount is not recognizable.'
		fromAid = None
		while fromAid is None:
			try:
				fromAid = int(input("From account ID: "))
			except:
				print 'Error: The account id is not recognizable.'
		toAid = None
		while toAid is None:
			try:
				toAid = int(input("To account ID: "))
			except:
				print 'Error: The account id is not recognizable.'
		if fromAid == toAid:
			print 'Error: the accounts indicated are the same.'
		else:
			print bank.transfer( fromAid, toAid, amount )
		return True

	def removeAccount( self, bank ):
		"""
		Not yet implemented.
		Allows the user to remove an account
		"""
		pass

	def viewBalance( self, bank ):
		"""
		Obtains the balance of an account
		"""
		print "Check Account Balance:"
		Aid = None
		while Aid is None:
			try:
				Aid = int(input("Account ID: "))
			except:
				print 'Error: The account id is not recognizable.'
		print bank.viewBalance(Aid)
		return True

	def getAccountHistory( self , bank):
		"""
		Provides the history for an account
		"""
		print "Account History:"
		Aid = None
		while Aid is None:
			try:
				Aid = int(input("Account number: "))
			except:
				print 'Error: The account id is not recognizable.'
		print bank.getAccountHistory(Aid)
		return True

	def listAllAccounts( self, bank ):
		"""
		Provides a list of every account along with its balance
		"""
		print bank.listAccounts()
		return True

	def scheduleDeposit( self, bank ):
		print "Schedule Deposit:"
		time = None
		while time is None:
			try:
				time = int(input("Enter time to operation [seconds]: "))
			except:
				print 'Error: The time to operation is not recognizable.'
		Aid = None
		while Aid is None:
			try:
				Aid = int(input("Account number: "))
			except:
				print 'Error: The account id is not recognizable.'
		amount = None
		while amount is None:
			try:
				amount = float(input("Amount to deposit: "))
			except:
				print 'Error: The amount is not recognizable.'
		if Aid < 0 or amount < 0 or time < 0:
			print 'Values should be greater than zero'
		else:
			#Operations are sent to scheduler as 2 102 w 200
			cmd = [time,Aid,'d',amount]
			self.__scheduler.getLock()
			self.__scheduler.addtoQueue(cmd)
			self.__scheduler.setUnlock()
			self.__scheduler.setNewCommand()
			self.__scheduler.setWake()
		return True

	def scheduleWithdraw( self, bank ):
		print "Schedule Whithdraw:"
		time = None
		while time is None:
			try:
				time = int(input("Enter time to operation [seconds]: "))
			except:
				print 'Error: The time to operation is not recognizable.'
		Aid = None
		while Aid is None:
			try:
				Aid = int(input("Account number: "))
			except:
				print 'Error: The account id is not recognizable.'
		amount = None
		while amount is None:
			try:
				amount = float(input("Amount to withdraw: "))
			except:
				print 'Error: The amount is not recognizable.'
		if Aid <0 or amount < 0 or time < 0:
			print 'Values should be greater than zero'
		else:
			#Operations are sent to scheduler as 2 102 w 200
			cmd = [time,Aid,'w',amount]
			self.__scheduler.getLock()
			self.__scheduler.addtoQueue(cmd)
			self.__scheduler.setUnlock()
			self.__scheduler.setNewCommand()
			self.__scheduler.setWake()
		return True


	def scheduleTransfer( self, bank ):
		print "Schedule Transfer:"
		time = None
		while time is None:
			try:
				time = int(input("Enter time to operation [seconds]: "))
			except:
				print 'Error: The time to operation is not recognizable.'
		fromAid = None
		while fromAid is None:
			try:
				fromAid = int(input("From account number: "))
			except:
				print 'Error: The account id is not recognizable.'

		toAid = None
		while toAid is None:
			try:
				toAid = int(input("To account number: "))
			except:
				print 'Error: The account id is not recognizable.'
		
		amount = None
		while amount is None:
			try:
				amount = float(input("Amount to transfer: "))
			except:
				print 'Error: The amount is not recognizable.'
		if toAid <0 or fromAid <0 or amount < 0 or time < 0:
			print 'Values should be greater than zero'
		elif fromAid == toAid:
			print 'Error: the accounts indicated are the same.'
		else:
			print bank.transfer( fromAid, toAid, amount )
			#Operations are sent to scheduler as 2 102 w 200
			cmd = [time,fromAid,'t',toAid,amount]
			self.__scheduler.getLock()
			self.__scheduler.addtoQueue(cmd)
			self.__scheduler.setUnlock()
			self.__scheduler.setNewCommand()
			self.__scheduler.setWake()
		return True

		

	def viewSchedule(self, bank):
		"""
		Outputs a list of the scheduled activities
		"""
		self.__scheduler.getLock()
		schedule, delta = self.__scheduler.getSchedule()
		self.__scheduler.setUnlock()
		print "LIST OF SCHEDULED OPERATIONS"
		if schedule:
			for operation in schedule:
				print "IN:",(int(operation[0])-int(delta)),"seconds","account:",operation[1],"DO:",operation[2]
		else:
			print "No operation was schedule"
		return True

	def about( self, bank ):
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

	def getHelp( self, bank ):
		"""
		Outputs the allowed commands
		"""
		print "\n---- SOD - Bank Managment ----"
		print "List of known commands"
		print "0: exit"
		print "1: menu"
		print "2: about"
		print "3: create account"
		print "4: deposit money"
		print "5: withdraw money"
		print "6: transfer money"
		print "7: view balance"
		print "8: view movements"
		print "9: list all accounts"
		print "10: schedule deposit"
		print "11: schedule withdraw"
		print "12: schedule transfer"
		print "13: view scheduled operations\n"
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
	
	def sendCommand(self, cmd, bank):
		"""
		Executes the command
		"""
		return cmd(bank)


	def exit( self, bank ):
		"""
		Allows the user to terminate the client program
		"""
		#TODO: sinalizar servidor que sai?
		
		#terminates the thread scheduler
		if self.__scheduler is not None:
			self.__scheduler.setWake()
		else:
			print 'Scheduler does not exists.'
		
		for thread in enumerate():
			if thread is not currentThread():
				if activeCount() is 1:
					break
				print 'Closing... ('+str(activeCount()-1)+')'
				thread.join()
		return False
