#!/usr/bin/env python
# -*- coding: utf-8 -*- 


"""
The global lock preserves corectness of transactions by deducting money 
only when available. This allows the database to be multithreaded and 
accept requests concurrently.
"""


from threading import Lock


class GlobalLock:

	def __init__( self ):
		self.__entitys = {}
		self.__lock = None

	def Close( self ):
		pass

	def acquire( self, entity, Id ):
		if self.__lock is None:
			self.__lock = Lock()
		self.__lock.acquire()
		token = self.__Read( entity, Id, True)
		token[1] += 1
		self.__lock.release()
		
		token[0].acquire()
		token[1] -= 1

	def release( self, entity, Id ): 
		if self.__lock is None:
			raise ValueError( 'Impossible to make a release account '+str(Id) ) 
		self.__lock.acquire()
		lock = self.__Read( entity, Id, False )
		if self.__lock is None:
			raise ValueError( 'Impossible to make a release account '+str(Id) ) 
		self.__lock.release()
		if lock is None:
			raise ValueError( 'Impossible to make a release account '+str(Id) )
		lock.release()
		if not self.__entitys:
			print 'QUER APAGAR LOCK', Id
		#	temp = self.__lock
		#	self.__lock = None
		#	del temp

	def __Read( self, entity, Id, Assign ):
		entityName = str( entity )
		entityId = str( id(entity) )
		
		entity = self.__entitys.get( entityId, None )
		if entity is None:
			if Assign:
				self.__entitys[ entityId ] = {}
				entity = self.__entitys[ entityId ]
			else:
				raise ValueError( "The entity provided does not have any lock assigned: "+entityName )
		
		token = entity.get( str( Id ), None )
		if token is None:
			if Assign:
				entity[ str( Id ) ] = [ Lock(), 0 ]
				token = entity[ str( Id ) ]
			else:
				raise ValueError( "The id provided does not have a lock assigned: "+str(Id)+" from "+entityName )
		
		if not Assign:
			waiting = token[1]
			token = token[0]
			if waiting is 0:
				temp = entity.pop( str(Id) )
				del temp
				if not entity:
					temp = self.__entitys.pop( entityId )
					del temp
		
		return token
