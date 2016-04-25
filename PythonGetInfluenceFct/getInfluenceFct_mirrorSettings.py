#!/usr/bin/env python
#
# Copyright (C) 2014/2015 Steffen Mauch <steffen.mauch (at) unorthodox-solutions.de>
#
# $Id: getInfluenceFct_mirrorSettings.py 1737 2015-06-30 21:09:55Z smauch $
#
# This file should be used with the US_FPGA_AO Card, developped by Steffen Mauch
# It automatically captures the influence function of an deformable mirror
# by deflecting the actuators and capturing the deformation via an SHWFS.
# The values are stored in a .mat file to be further processed e.g. by Matlab.
# The US_FPGA_AO card is accessed via comedi and for python pycomedi is used.
#
#
# It is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 2 of the License, or (at your option) any later
# version.
#
# pycomedi is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# pycomedi.  If not, see <http://www.gnu.org/licenses/>.

import numpy as _numpy
import StringIO 
import sys
from collections import namedtuple
from datetime import datetime

svnid = '$Id: getInfluenceFct_mirrorSettings.py 1737 2015-06-30 21:09:55Z smauch $'
MyStruct = namedtuple("MyStruct", "offsetChannel listChannels orderChannel maxVolt defaultVolt log")
MySlopes = namedtuple("MySlopes", "slopeX slopeY")


def tiptTilt():
	# create a 64 array with zeros; meaning that no channel
	# will be biased with _defaultVolt
	_listChannels = 64*[1]

	# offset of the start of channel for _listChannels, no meaning for
	# _orderChannel at all!
	_offsetChannel = 0

	# determines which channel (actuator) is deflected first
	_orderChannel = [30,31]

	# WHICH INPUT RANGE HAS THE TIPTILT mirror
	_defaultVolt = _numpy.floor( 1*(2**15-1) )
	_maxVolt     = _numpy.floor( 1*(2**12-1) )

	# create StringIO for logging purpose
	_log = StringIO.StringIO()
	_log.write("_tiptTilt - %s\n" % ( svnid ) )
	_log.write("_listChannels:\n%s\n" % ( str(_listChannels) ))
	_log.write("_offsetChannel:\n%s\n" % ( str(_offsetChannel) ))
	_log.write("_orderChannel:\n%s\n" % ( str(_orderChannel) ))
	_log.write("_defaultVolt:\n%s\n" % ( str(_defaultVolt) ))
	_log.write("_maxVolt:\n%s\n" % ( str(_maxVolt) ))

	ret = MyStruct( offsetChannel = _offsetChannel, listChannels = _listChannels,
		orderChannel = _orderChannel, defaultVolt = _defaultVolt,
		maxVolt = _maxVolt, log = _log)

	return ret


def mirrorSTE_24Act():
	# create a 64 array with ones; meaning that every channel
	# will be biased with the _defaultVolt
	# a zero means, this channel will be zero!
	_listChannels = 64*[1]
	#_listChannels[2] = 0
	#_listChannels[3] = 0

	# offset of the start of channel for _listChannels, no meaning for
	# _orderChannel at all!
	_offsetChannel = 0

	# determines which channel (actuator) is deflected first
	#_orderChannel = [12]
	#_orderChannel = range(0,64)
	_orderChannel = [43,45,11,12, 4, 6,46,40,   
		44,34,32,42,14,21,26,18,19, 1, 5, 3,49,47,38,41]

	_defaultVolt = _numpy.floor( 1*(2**15-1) )
	_maxVolt     = _numpy.floor( 1*(2**15-1) )

	# create StringIO for logging purpose
	_log = StringIO.StringIO()
	_log.write("_mirrorSTE_24Act - %s\n" % ( svnid ) )
	_log.write("_listChannels:\n%s\n" % ( str(_listChannels) ))
	_log.write("_offsetChannel:\n%s\n" % ( str(_offsetChannel) ))
	_log.write("_orderChannel:\n%s\n" % ( str(_orderChannel) ))
	_log.write("_defaultVolt:\n%s\n" % ( str(_defaultVolt) ))
	_log.write("_maxVolt:\n%s\n" % ( str(_maxVolt) ))

	ret = MyStruct( offsetChannel = _offsetChannel, listChannels = _listChannels,
		orderChannel = _orderChannel, defaultVolt = _defaultVolt,
		maxVolt = _maxVolt, log = _log)

	return ret

def mirrorSTE_40Act():
	# create a 64 array with ones; meaning that every channel
	# will be biased with the _defaultVolt
	# a zero means, this channel will be zero!
	_listChannels = 64*[1]

	# offset of the start of channel for _listChannels, no meaning for
	# _orderChannel at all!
	_offsetChannel = 0

	# determines which channel (actuator) is deflected first
	_orderChannel = [43,45,11,12, 4, 6,46,40,
		44,34,32,42,14,21,26,18,19, 1, 5, 3,49,47,38,41,
		35,36,33,10,20,15,13,16, 0, 8, 7, 2,48,37,50,51]

	_defaultVolt = _numpy.floor( 1*(2**15-1) )
	_maxVolt     = _numpy.floor( 1*(2**15-1) )

	# create StringIO for logging purpose
	_log = StringIO.StringIO()
	_log.write("_mirrorSTE_40Act - %s\n" % ( svnid ) )
	_log.write("_listChannels:\n%s\n" % ( str(_listChannels) ))
	_log.write("_offsetChannel:\n%s\n" % ( str(_offsetChannel) ))
	_log.write("_orderChannel:\n%s\n" % ( str(_orderChannel) ))
	_log.write("_defaultVolt:\n%s\n" % ( str(_defaultVolt) ))
	_log.write("_maxVolt:\n%s\n" % ( str(_maxVolt) ))

	ret = MyStruct( offsetChannel = _offsetChannel, listChannels = _listChannels,
		orderChannel = _orderChannel, defaultVolt = _defaultVolt,
		maxVolt = _maxVolt, log = _log)

	return ret
