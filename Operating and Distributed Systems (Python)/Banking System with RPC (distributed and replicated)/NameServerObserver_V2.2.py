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


from wxAnyThread import anythread
import sys
import wx
from threading import Thread, Event, enumerate, currentThread, activeCount
from Pyro.naming import NameServerStarter, NameServerLocator
from Pyro.errors import PyroError
import Pyro


class Frame( wx.Frame ):

	welcomeMSG = '\
#INSTITUTO SUPERIOR TÉCNICO 2010/2011\n\
#Operating and Distributed Systems\n\
#\n\
#\tCode written by:\n\
#\t\tFilipe Funenga\t\tfilipe.funenga@ist.utl.pt\t\t(57977)\n\
#\t\tMartim Camacho\tmartim.camacho@ist.utl.pt\t(56755)\n\
#\t\tPedro Silva\t\tpedro.silva@ist.utl.pt\t\t(58035)\n\
#\n\
#	Credits:\n\
#		 Pyro is written and © by Irmen de Jong\n\
#		 Software license at: http://www.xs4all.nl/~irmen/pyro3/manual/LICENSE\n'

	def __init__( self ):
		wx.Frame.__init__( self, None, wx.ID_ANY, 'Name Server Observer', size=wx.Size(550,-1) )
		self.__state = False
		self.__nsStarter = None
		self.__ns = None
		self.__build()
		self.Show()
		self.Bind( wx.EVT_CLOSE, self.__OnClose )

	def __build( self ):
		line1 = self.__lineIpAddress()
		line2 = self.__linePort()
		button = self.__startButton()
		log = self.__log()
		buttonTree = self.__showTreeButton()
		tree = self.__showTree()
		sizer = wx.BoxSizer( wx.VERTICAL )
		sizer.Add( line1, 0, wx.EXPAND )
		sizer.Add( line2, 0, wx.EXPAND )
		sizer.Add( button, 0, wx.ALIGN_RIGHT )
		sizer.Add( log, 1, wx.EXPAND )
		sizer.Add( buttonTree, 0, wx.ALIGN_RIGHT)
		sizer.Add( tree, 1, wx.EXPAND )
		self.SetSizer( sizer )

	def __lineIpAddress( self ):
		label = wx.StaticText( self, wx.ID_ANY, 'IP address:')
		self.ipAddress = wx.TextCtrl( self )
		self.ipAddress.SetValue( '127.0.0.1' )
		sizer = wx.BoxSizer( wx.HORIZONTAL )
		sizer.Add( label, 0, wx.EXPAND )
		sizer.Add( self.ipAddress, wx.EXPAND )
		return sizer

	def __linePort( self ):
		label = wx.StaticText( self, wx.ID_ANY, 'Port:')
		self.port = wx.TextCtrl( self )
		self.port.SetValue( '9090' )
		sizer = wx.BoxSizer( wx.HORIZONTAL )
		sizer.Add( label, 0, wx.EXPAND )
		sizer.Add( self.port, wx.EXPAND )
		return sizer

	def __startButton( self ):
		self.button = wx.Button( self, wx.ID_ANY, 'Start NS')
		self.Bind( wx.EVT_BUTTON, self.OnButton, self.button )
		return self.button

	def __log( self ):
		class Output( wx.TextCtrl ):
			def __init__(self, parent):
				wx.TextCtrl.__init__(	self, parent, wx.ID_ANY,
										style = wx.TE_MULTILINE| wx.TE_READONLY | wx.HSCROLL )
				self.WriteText( Frame.welcomeMSG )
			@anythread
			def PrintMsg( self, msg ):
				self.SetInsertionPointEnd()
				self.WriteText( msg )
				self.Update()
		
		class redirectText:
			def __init__( self, out ):
				self.out = out
			def write(self,string):
				self.out.PrintMsg(string)
		
		self.log = Output( self )
		sys.stdout=redirectText( self.log )
		return self.log

	def __showTreeButton( self ):
		self.buttonTree = wx.Button( self, wx.ID_ANY, 'Show Names')
		self.Bind( wx.EVT_BUTTON, self.OnShowNames, self.buttonTree )
		self.buttonTree.Disable()
		return self.buttonTree

	def __showTree( self ):
		self.tree = wx.TextCtrl(	self, wx.ID_ANY,
									style = wx.TE_MULTILINE | wx.TE_READONLY | wx.HSCROLL )
		return self.tree

	def OnButton( self, event ):
		if self.__state:
			self.__OnStop()
		else:
			self.__OnStart()
		self.__state = not self.__state

	def OnShowNames( self, event ):
		if not self.button.GetLabel() == 'Stop':
			self.tree.SetInsertionPoint(0)
			self.tree.WriteText( '--> The Name Server needs to be started first <--\n' )
			return
		
		if self.__ns is None:
			self.__ns = NameServerLocator().getNS()
		
		def join(part1,part2):
			if part2[0]==':':
				return part2
			elif part1==':':
				return part1+part2
			else:
				return part1+'.'+part2
		def _listsub(ns, parent,name,level, string):
			newgroup = join(parent,name)
			list = ns.list(newgroup)
			string += '    '*level+'['+name+']'+'\n'
			temp = ''
			for (subname,type) in list:
				if type==0:		# group
					temp = _listsub(ns,newgroup,subname,level+1, '')+'\n'
				elif type==1:	# object name
					temp = '    '*(1+level)+subname+'\n'
			return string + temp
		def listNamespace(ns):
			string = '--- namespace tree listing ---'+'\n'
			string += _listsub(ns,'',':',0, '')+'\n'
			string += '-------'+'\n'
			return string
		
		self.tree.Clear()
		for temp in self.__ns.flatlist():
			self.tree.WriteText( str(temp[0])+' '+str(temp[1].address)+'\n' )

	def __OnStart( self ):
		print '---'
		print 'Starting NameServer...'
		host = self.ipAddress.GetValue()
		try:
			port = int( self.port.GetValue() )
		except:
			self.port.Clear()
			return
		
		self.__nsStarter = NameServerStarter()
		
		class nssThread( Thread ):
			def __init__( self, nss, host, port, cancel ):
				Thread.__init__( self )
				self.__args = [ nss, host, port, cancel ]
				self.start()
			def run( self ):
				try:
					self.__args[0]( self.__args[1], self.__args[2] )
				except PyroError, error:
					self.__args[3].flag = False
		
		self.flag = True
		nssThread( self.__nsStarter.start, host, port, self )
		self.button.Disable()
		Thread( target=self.waitForNS ).start()

	def __OnStop( self, flag=True ):
		print '---'
		print 'Closing NameServer...'
		self.__nsStarter.shutdown()
		self.button.Disable()
		if flag:
			self.thread = currentThread()
			Thread( target=self.waitForStop ).start()
		self.__ns = None

	def waitForNS( self ):
		while self.flag:
			if self.__nsStarter.waitUntilStarted(1):
				self.__OnMode()
				break
			if not self.flag:
				self.__state = not self.__state
				self.button.Enable()
				break
		return

	def waitForStop( self ):
		cThread = currentThread()
		for thread in enumerate():
			if thread is not cThread:
				if thread is not self.thread:
					if activeCount() is 2:
						break
					thread.join()
		self.__OffMode()
		self.__ns = None

	@anythread
	def __OnMode( self ):
		self.ipAddress.SetEditable(False)
		self.ipAddress.SetBackgroundColour('grey')
		self.port.SetEditable(False)
		self.port.SetBackgroundColour('grey')
		self.button.SetLabel( 'Stop' )
		self.buttonTree.Enable()
		self.button.Enable()
		self.Refresh()

	@anythread
	def __OffMode( self ):
		self.ipAddress.SetEditable(True)
		self.ipAddress.SetBackgroundColour('white')
		self.port.SetEditable(True)
		self.port.SetBackgroundColour('white')
		self.button.SetLabel( 'Start NS' )
		self.buttonTree.Disable()
		self.button.Enable()
		self.Refresh()

	def __OnClose( self, event ):
		if self.__state:
			self.__OnStop( False )
		self.Destroy()


class Application( wx.App ):
	def __init__(self, redirect=False, filename=None):
		wx.App.__init__(self, redirect, filename)

	def OnInit(self):
		Frame()
		return True


if __name__ == '__main__':
	Pyro.config.PYRO_NS_URIFILE = None
	app = Application( True )
	app.MainLoop()
