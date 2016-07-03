#!/usr/bin/env python
# -*- coding: utf8 -*-
# Description:
#	There is a monkey which can walk around on a planar grid. 
#	The monkey can move one space at a time left, right, up or down. 
#	That is, from (x, y) the monkey can go to (x+1, y), (x-1, y), 
#	(x, y+1), and (x, y-1). Points where the sum of the digits of the 
#	absolute value of the x coordinate plus the sum of the digits of 
#	the absolute value of the y coordinate are lesser than or equal to
#	19 are accessible to the monkey. For example, the point (59, 79) 
#	is inaccessible because 5 + 9 + 7 + 9 = 30, which is greater than 
#	19. Another example: the point (-5, -7) is accessible because 
#	abs(-5) + abs(-7) = 5 + 7 = 12, which is less than 19. How many 
#	points can the monkey access if it starts at (0, 0), 
#	including (0, 0) itself?
#
# Input sample:
#	There is no input for this program.
#
# Output sample:
#	Print the number of points the monkey can access. 
#	It should be printed as an integer — for example, if the number of 
#	points is 10, print "10", not "10.0" or "10.00", etc.
#
# Code written by Pedro Silva
# Last revision: 19.07.2012


"""
This file contains class definition for solving a grid walk problem
"""
class Movements:
	MAX_SUM = 0
	visited = {}
	
	def __init__(self, max):
		self.MAX_SUM = max;
	
	def __checkposition( self, position):
		"""
		Computes the digit sum of two numbers and checks if it is equal 
		or below the given threshold. In that case the return is set to 
		TRUE and FALSE otherwise.
		Example:
			(11,12) -> 1+1+1+2 = 5
			if 5 <= MAX_SUMM then TRUE else FALSE
		"""
		for (x,y) in position:
			sum = self.__digitsum(x)+self.__digitsum(y);
		return sum <= self.MAX_SUM;

	def __digitsum( self, value):
		"""
		Computes the digit sum of a number
		Example:
			20 -> 2+0 = 2
		"""
		value = str(abs(value));
		sum   = 0;
		for digit in value:
			sum += int(digit)
		return sum;

	def moveongrid( self, moves ):
		"""
		For each 2D coordinate in MOVES this function checks the WEST,
		EAST, NORTH and SOUTH neighbours and validates them. The 
		valid neighbours (define by checkposition) are marked as visited
		and pushed into the verification stack
		"""
		coordinate = moves.pop(0)
		for (x,y) in [coordinate]:
			for movement in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
				if self.__checkposition([movement]) and not self.visited.get(movement):
					self.visited[movement]=1
					moves.append(movement)
				else:
					continue

if __name__ == '__main__':
	"""
	Prints the number of coordinates accessible in a planar (2D) grid 
	which have a digit sum less or equal to 19. This number is the size 
	of the dictionary which contains the visited and accessible positions
	on the 2D grid.
	The processing ends when the stack with the next coordinates to check
	is empty.
	"""
	moves = Movements(19)
	movesleft = [(0,0)]
	while movesleft:
		moves.moveongrid(movesleft)
	print len(moves.visited)
