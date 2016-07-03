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
File contains the class to read and parse the arguments passed to the program.
"""

class CmdLine:
	"""
	Parses and sets the arguments given to the program by the OS
	"""
	
	#usage message
	usageMsg = "usage: python client.py [option=value] [option]..."
	hintMsg = "use \'python client.py h\' to see the help menu."
	helpMsg = "\
usage: python client.py [option=value] [option]...\n\
	nh=hostname\t\tNameServer hostname.\n\
	np=port\t\t\tNameServer port.\n\
	g=group\t\t\tThe group to look up at the NameServer.\n\
	f=file\t\t\tFile to initialize the client scheduler.\n\
	b\t\t\tActivates benchmarking.\n\
	v\t\t\tActivates debug.\n\
	h\t\t\tDisplay this help menu."

	#Default Values
	NSHOSTNAME = 'localhost'
	NSPORT = 9090
	GROUP = ':BFTP'
	FILE = []
	BENCHMARK = False
	VERBOSE = False

	def __init__( self ):
		self.__optsTarget={	'nh': 'nhostname',
							'np': 'nport',
							'g': 'group',
							'b': 'benchmark',
							'v': 'verbose',
							'f': self.file,
							'h': self.help }
							
		self.options = {'nhostname': self.NSHOSTNAME,
						'nport': self.NSPORT,
						'group':self.GROUP,
						'benchmark':self.BENCHMARK,
						'verbose':self.VERBOSE,
						'file': self.FILE }

	def Analyse( self, args ):
		"""
		Checks for a valid arguments.
		In case of success it is set, otherwise the program exits with a usage message
		"""
		for arg in args:
			cmd = arg.split( '=' )
			l = len( cmd )
			
			if l>0:
				optTarget = self.__optsTarget.get( cmd[0], None )
				if optTarget is None:
					return self.hintMsg

				if isinstance( optTarget, str ):
					if l>1:
						if isinstance( self.options[ optTarget ], int ):
							if self.options[ optTarget ]:
								try:
									cmd[1] = int(cmd[1])
								except:
									return 'Error in '+cmd[0]+'.\n'+self.hintMsg
							else:
								return 'Error in '+cmd[0]+'.\n'+self.hintMsg
						self.options[ optTarget ] = cmd[1]
					else:
						if not isinstance( self.options[ optTarget ], bool ):
							return 'Error: '+cmd[0]+'\n'+self.hintMsg
						self.options[ optTarget ] = True
				else:
					try:
						if l is 1:
							rsp = optTarget()
						elif l is 2:
							rsp = optTarget( cmd[1] )
						if isinstance( rsp, str ):
							return rsp
					except:
						return 'Error: '+cmd[0]+'\n'+self.hintMsg
			else:
				return self.hintMsg
		
		# group needs to begin with ':'
		if self.options['group'] == '' or self.options['group'] == ':': 
			return 'Error: g'+'\n'+self.hintMsg
		elif self.options[ 'group' ][0] is not ':':
			self.options[ 'group' ] = ':'+self.options[ 'group' ]

	def file( self, fname ):
		"""
		This function implements the parsing of the server init file.
		"""
		if fname == '':
			return 'Error: filename was not given.'
		try:
			f = open(fname,"r")
		except:
			return 'The specified file was not found: \''+fname+'\''

		#reads each line of the file to a list
		lines = []
		lineCounter = 1
		for line in f.readlines():
			tmp = line.replace(',',' ')
			tmp = tmp.split()
			if tmp[2] == 'd' or tmp[2] == 'w' or tmp[2] == 't':
				lines.append(tmp)
				lineCounter += 1
			else:
				f.close()
				return 'Error reading file. Wrong format at line: '+str(lineCounter)+'\nusage: time_stamp account_number operation balance_amount'

		#Closes the file and saves the lines
		f.close()
		self.options['file'] = lines


	def help( self ):
		return self.helpMsg

