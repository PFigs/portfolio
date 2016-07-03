#!/usr/bin/env python
# -*- coding: utf8 -*-

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
This file contains the main function for the client program
"""

from Pyro.constants import VERSION
if not VERSION == '3.10':
	print 'Not compatible with current Pyro version(',VERSION,').'
	print 'Developed for version: 3.10.'
	exit()

import sys
from ClientLibs import Client
from ClientLibs.cmdLine import CmdLine

if __name__ == '__main__':

	cl = CmdLine()
	rsp = cl.Analyse( sys.argv[1:] )
	if not isinstance( rsp, str ):
		rsp = Client( cl.options ).Run()
	print rsp
