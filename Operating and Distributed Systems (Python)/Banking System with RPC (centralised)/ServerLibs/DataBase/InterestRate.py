#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Interest rate is bank service that periodically deposits an interest
amount to each account in the database based on some fixed rate.
"""


from time import time
from threading import Thread, Event, Lock


class InterestRateManager( Thread ):

	#DEFAULT VALUES
	PERIOD = 10*60 # in Seconds
	RATE = 0.05

	def __init__( self, accounts, depositInterest, rate = 0.05 ):
		self.RATE = rate
		Thread.__init__( self )
		self.__accounts = accounts
		self.__handler = depositInterest
		self.__schedule = []
		self.__lock = Lock()
		self.__terminateFlag = False
		self.__event = Event()
		self.start()

	def ScheduleDeposit( self, Aid ):
		if not self.__schedule:
			flag = True
		else:
			flag = False
		begining = self.__accounts[ str(Aid) ][ 'AdateOfBegin' ]
		self.__lock.acquire()
		self.__schedule.append( [ Aid, begining, 0 ] )
		self.__lock.release()
		if flag:
			self.__event.set()

	def Close( self ):
		self.__terminateFlag = True
		self.__event.set()

	def __CalcTimeToNext( self ):
		timeToWait = time()-self.__schedule[0][1]
		n = int( timeToWait / self.PERIOD )
		if n > self.__schedule[0][2]:
			return 0
		else:
			timeToWait = timeToWait%self.PERIOD
			timeToWait = self.PERIOD-timeToWait
			return timeToWait

	def run( self ):
		while True:
			#Thread waits for event or timeout
			if self.__schedule:
				timeToWait = self.__CalcTimeToNext()
				self.__flag = True
				self.__event.clear()
				self.__event.wait( timeToWait )
			else:
				self.__flag = False
				self.__event.clear()
				self.__event.wait()
			
			if self.__event.is_set():	#Close, First ScheduleDeposit
				if self.__terminateFlag:
					break
			else:	#timeout
				if self.__accounts.get( str( self.__schedule[0][0] ), None ) is None:
					self.__deleteInterest()
				else:
					self.__applyRotationInterest()

	def __applyRotationInterest( self ):
		self.__lock.acquire()
		event = self.__schedule.pop(0)
		self.__handler( str( event[0] ), self.RATE )
		event[2] += 1
		self.__schedule.append( event )
		self.__lock.release()

	def __deleteInterest( self ):
		self.__lock.acquire()
		self.__schedule.pop( 0 )
		self.__lock.release()
