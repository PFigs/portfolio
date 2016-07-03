#!/ur/bin/env python
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


from Pyro.constants import VERSION
if not VERSION == '3.10':
	print 'Not compatible with current Pyro version(',VERSION,').'
	print 'Developed for version: 3.10.'
	exit()

import sys
from ServerLibs import Server
from ServerLibs.cmdLine import CmdLine


#python servidor.py [n=name] [g=group] [sh=serverHostname] [sp=porto] [nh=nsHostname] [np=nsPort] [f=cfile] [h]


if __name__ == '__main__':

	cl = CmdLine()
	rsp = cl.Analyse( sys.argv[1:] )
	if isinstance( rsp, str ):
		print rsp
	else:
		server = Server( cl.options )
		print server.RunInterface()