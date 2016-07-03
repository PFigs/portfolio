#!/usr/bin/env python
# -*- coding: utf-8 -*-

# 	Instituto Superior Técnico 2010/2011
#    Operating and Distributed Systems
#
#   Code written by:
#		Filipe Funenga filipe.funenga@ist.utl.pt (57977)
#		Martim Camacho martim.camacho@ist.utl.pt (56755)
#		Pedro Silva    pedro.silva@ist.utl.pt    (58035)


class CmdLine:

	usageMsg = "usage: python server.py [option=value] [option]..."
	hintMsg = "use \'python server.py h\' to see the help menu."
	helpMsg = "\
usage: python server.py [option=value] [option]...\n\
	sh=serverHostname\tServer hostname.\n\
	sp=serverPort\t\tServer port.\n\
	nh=nsHostname\t\tNameServer hostname.\n\
	np=nsPort\t\tNameServer port.\n\
	ph=publishHost\t\tThe serverHostname to publish at the NameServer.\n\
	g=group\t\t\tThe group to connect the server API at the NameServer.\n\
	n=name\t\t\tThe name to connect the server API at the NameServer.\n\
	f=file\t\t\tFile to initialize the server.\n\
	h\t\t\tDisplay this help menu.\
"
	#Default Values
	SHOSTNAME = 'localhost'
	SPORT = 9000
	NSHOSTNAME = 'localhost'
	NSPORT = 9001
	PUBLISHHOST = SHOSTNAME
	GROUP = ':BFTP'
	NAME = 'Agency'
	VERBOSE = False
	FILE = []

	def __init__( self ):
		self.__optsTarget={	'sh': 'serverHostname',
							'sp': 'serverPort',
							'nh': 'nsHostname',
							'np': 'nsPort',
							'ph': 'publishHost',
							'g': 'group',
							'n': 'name',
							'v': 'verbose',
							'f': self.file,
							'h': self.help }
		self.options = {'serverHostname': self.SHOSTNAME,
						'serverPort': self.SPORT,
						'nsHostname':self.NSHOSTNAME,
						'nsPort':self.NSPORT,
						'publishHost':self.PUBLISHHOST,
						'group':self.GROUP,
						'name':self.NAME,
						'verbose': self.VERBOSE,
						'file': self.FILE }

	def Analyse( self, args ):
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
							if isinstance( self.options[ optTarget ], bool ):
								return 'Error in '+cmd[0]+'.\n'+self.hintMsg
							try:
								cmd[1] = int(cmd[1])
							except:
								return 'Error in '+cmd[0]+'.\n'+self.hintMsg
						elif isinstance( self.options[ optTarget ], str ):
							if cmd[1]=='':
								return 'Error in '+cmd[0]+'.\n'+self.hintMsg
						self.options[ optTarget ] = cmd[1]
					else:
						if isinstance( self.options[ optTarget ], bool ):
							self.options[ optTarget ] = True
							continue
						else:
							return 'Error in '+cmd[0]+'.\n'+self.hintMsg
				else:
					try:
						if l is 1:
							rsp = optTarget()
						elif l is 2:
							rsp = optTarget( cmd[1] )
						if isinstance( rsp, str ):
							return rsp
					except:
						return 'Error in '+cmd[0]+'.\n'+self.hintMsg
			else:
				return self.hintMsg
		
		# if (sHost==nsHost) then (sPort != nsPort)
		if self.options['serverHostname'] == self.options['nsHostname']:
			if self.options['serverPort'] == self.options['nsPort']:
				return 'Error: The server\'s port can\'t be the same of the NameServer.'
		# group needs to begin with ':'
		if self.options[ 'group' ][0] is not ':':
			self.options[ 'group' ] = ':'+self.options[ 'group' ]

	def file( self, fname ):
		"""
		This method implements the parsing of the server init file.
		"""
		if fname == '':
			return 'Error: filename was not given.'
		try:
			f = open(fname,"r")
		except:
			return 'The specified file was not found: \''+fname+'\''
		
		lines = []
		lineCounter = 1
		for line in f.readlines():
			tmp = line.replace(',',' ')
			tmp = tmp.split()
			if len(tmp) is not 2:
				f.close()
				return 'FileError: Wrong format at line '+str(lineCounter)+'\nline-format: account_number, balance_amount'
			lines.append(tmp)
			lineCounter += 1
		
		f.close()
		self.options['file'] = lines

	def help( self ):
		return self.helpMsg
