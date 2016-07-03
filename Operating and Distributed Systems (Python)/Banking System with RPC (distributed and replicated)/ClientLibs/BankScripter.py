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
This file contains the thread thats control the sheduling of commands.
"""

import sys
from threading import Thread, Event
from time import sleep, time, ctime, localtime
from threading import Lock

class Scripter( Thread ):
	"""
	Obtains the contents of the init file.
	Dispatches every command for the time set in its timestamp.
	"""
	def __init__(self, bank, verbose, benchmark=False, filename="benchmark-", mode = 'a'):
		Thread.__init__(self)
		self.__bank = bank
		self.__wake = Event()
		self.__newCommand = Event()
		self.__commandQueue = list()
		self.__lock = Lock()
		self.__verbose = verbose
		self.__runtime = time()
		self.__started = time()
		if benchmark:
			self.__filename = filename + str(localtime().tm_mday) + '_' + str(localtime().tm_sec)
			self.__mode = mode
			self.__Measures = []
		else:
			self.__Measures = None

	def run(self):
		"""
		Scheduler main loop.
		The scheduler uses a sorted queue to get its commands. When the queue is empty the scheduler waits for an event.
		Its execution is controled by two thread events, wake and newCommand.
		These events either wake and exit (wake is set, newCommand is not) or wake and execute (booth set).
		"""
		run = True
		previous = 0
		while run:
			if self.__commandQueue:
				#calculates the time to rest
				action = int(self.__commandQueue[0][0]) - previous
				while  action > 0:
					self.getLock()
					self.__started = time()
					self.setUnlock()
					self.__wake.wait( action )
					if self.__wake.isSet() and self.__newCommand.isSet():
						self.clearWake()
						self.clearNewCommand()
						self.getLock()
						rest = round (time()-self.__started)
						self.setUnlock()
						action = int(self.__commandQueue[0][0]) - rest
					elif self.__wake.isSet():
						run = False
						break;
					else:
						break
					
				if not run:
					break;
				#obtains a command from the queue. Locks its access to prevent the client thread from changing its contents.
				self.getLock()
				entry = self.__commandQueue.pop(0)
				self.setUnlock()
				previous = int(entry[0])
				#executes the command 
				if entry[2]=='d':
					t1 = time()
					rsp = self.__bank.deposit((entry[1]),float(entry[3]))
					delta = time()-t1
				elif entry[2]=='w':
					t1 = time()
					rsp = self.__bank.withdraw((entry[1]),float(entry[3]))
					delta = time()-t1
				elif entry[2]=='t':
					t1 = time()
					rsp = self.__bank.transfer( entry[1], entry[3], float(entry[4]) )
					delta = time()-t1
				if self.__Measures is not None:
					self.__Measures.append( [ t1, delta, entry[1], entry[2], entry[3] ] )
				if(self.__verbose):
					print "\nScheduler:", entry[2],"@", entry[1], "Amount:", entry[3],
					if self.__Measures is not None:
						print '\tElapsed time:',delta,'seconds'
			else:
				self.__wake.wait()
				if self.__newCommand.isSet():
					self.clearWake()
					self.clearNewCommand()
				else:
					self.clearWake()
					break

		if self.__Measures is not None:
			self.write(self.__Measures)
			
		
		if(self.__verbose):
			print '\nScheduler exited with success'


	def setWake(self):
		"""
		Tells the scheduler to wake up
		"""
		self.__wake.set()
	
	def setNewCommand(self):
		"""
		Informs the scheduler about a new command.
		Needs to be set to prevent the schedule from exiting after a wake up.
		"""
		self.__newCommand.set()
	
	def clearWake(self):
		"""
		Clears the set on wake
		"""
		self.__wake.clear()
	
	def clearNewCommand(self):
		"""
		Clears the set on newCommand
		"""
		self.__newCommand.clear()
		
	def addtoQueue(self, command):
		"""
		Adds a command to the execution queue. The commands are sorted by time.
		"""

		#Updates the time to run
		if self.__commandQueue:
			command[0] = format(int(command[0]) + round(self.__started-time()),'.0f')
		if not self.__commandQueue:
			self.__commandQueue.append(command)
			self.__runtime = time()
		else:
			for i in range(0,len(self.__commandQueue)):
				if int(command[0]) < int(self.__commandQueue[i][0]):
					self.__commandQueue.insert(i,command)
					return True
				else:
					continue
			self.__commandQueue.insert(i+1,command)
			return False

	def write( self, data ):
		"""
		Writes to file
		Format:
			time_start \t time_to_complete \t operation
		"""
		file = open( self.__filename, self.__mode )
		file.write("BENCHMARK RESULTS FOR " + ctime() +'\n')
		for entry in data:
			file.write( str(entry[0]) + '\t' + str(entry[1]) + '\t' +  str(entry[3]) + '\n' )
		file.close()

	def isEmpty(self):
		"""
		Returns the size of the queue
		"""
		return len(self.__commandQueue)

	def getLock(self):
		"""
		Acquires the lock
		"""
		self.__lock.acquire()

	def setUnlock(self):
		"""
		Releases the lock
		"""
		self.__lock.release()

	def getSchedule(self):
		"""
		Returns the list of scheduled operations
		"""
		return self.__commandQueue, round(time() - self.__runtime)
