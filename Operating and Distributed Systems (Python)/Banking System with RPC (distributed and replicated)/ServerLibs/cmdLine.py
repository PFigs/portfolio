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

	#Default Values
	SHOSTNAME = '127.0.0.1'
	SPORT = 9000
	NSHOSTNAME = '127.0.0.1'
	NSPORT = 9090
	PUBLISHHOST = SHOSTNAME
	GROUP = ':BFTP'
	NAME = 'Agency'
	VERBOSE = False
	FILE = []

	usageMsg = "usage: python server.py [option=value] [option]..."
	hintMsg = "use \'python server.py h\' to see the help menu."
	helpMsg = "\
usage: python server.py name [option=value] [option]...\n\
	name\t\t\tThe name to connect the server API at the NameServer.\n\
	sh=serverHostname\tServer hostname.\n\
	sp=serverPort\t\tServer port.\n\
	nh=nsHostname\t\tNameServer hostname.\n\
	np=nsPort\t\tNameServer port.\n\
	ph=publishHost\t\tThe serverHostname to publish at the NameServer.\n\
	g=group\t\t\tThe group to connect the server API at the NameServer.\n\
	h\t\t\tDisplay this help menu.\
"

	def __init__( self ):
		self.__optsTarget={	'sh': 'serverHostname',
							'sp': 'serverPort',
							'nh': 'nsHostname',
							'np': 'nsPort',
							'ph': 'publishHost',
							'g': 'group',
							'v': 'verbose',
							'h': self.__help }
		self.options = {'serverHostname': self.SHOSTNAME,
						'serverPort': self.SPORT,
						'publishHost':self.PUBLISHHOST,
						'nsHostname':self.NSHOSTNAME,
						'nsPort':self.NSPORT,
						'group':self.GROUP,
						'name':self.NAME,
						'verbose': self.VERBOSE,
						'file': self.FILE }

	def __file( self, fname ):
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
			if len(tmp) == 0:
				print 'Warning -> line', str(lineCounter), 'ignored.'
				continue
			if len(tmp) is not 2:
				f.close()
				return 'FileError: Wrong format at line '+str(lineCounter)+'\nline-format: account_number, balance_amount'
			lines.append(tmp)
			lineCounter += 1
		
		f.close()
		self.options['file'] = lines

	def __help( self ):
		return self.helpMsg

	def analyse( self, args ):
		if len(args) == 0:
			return 'Error: The name to connect the server API at the NameServer is required'
		else:
			self.options['name'] = args[0]

		rsp = self.__file( './ServerLibs/.conf/accounts.conf' )

		if isinstance( rsp, str ):
			return rsp
		
		for arg in args[1:]:
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
						if isinstance( rsp, str ):
							return rsp
					except:
						return 'Error in '+cmd[0]+'.\n'+self.hintMsg
			else:
				return self.hintMsg
