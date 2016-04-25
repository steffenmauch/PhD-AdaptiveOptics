#!/usr/bin/env python
#
# Copyright (C) 2014/2015 Steffen Mauch <steffen.mauch (at) unorthodox-solutions.de>
#
# $Id: getInfluenceFct_general.py 1811 2015-08-06 06:59:16Z smauch $
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

import getInfluenceFct_mirrorSettings
import numpy as _numpy
import time
import os.path as _os_path
import scipy.io as sio


svnidGeneral = '$Id: getInfluenceFct_general.py 1811 2015-08-06 06:59:16Z smauch $'

from pycomedi.device import Device as _device
from pycomedi import channel as _channel
from pycomedi import constant as _constant
from pycomedi import utility as _utility
from pycomedi.chanspec import ChanSpec as _chanSpec

def setDefaultVoltage( subdevice, offsetChannel, listChannels, value ):

	insn = subdevice.insn()
	insn.insn = _constant.INSN.write
	insn.chanspec = _chanSpec(chan=offsetChannel, range=0, aref=0)
	cnt = len(listChannels)
	data = cnt*[value]

	for k in range(cnt):
		if listChannels[k] == 0:
			data[k] = 0

	insn.data = data

	return insn

def averageMeasurements( device, nbRepeats, triggerCmd, readCmd, fracBits ):
	slopeXZero = _numpy.uint32( 256*[0] )
	slopeYZero = _numpy.uint32( 256*[0] )
	
	for k in range( nbRepeats ):
		# signal trigger for slope reference measurement
		device.do_insnlist(triggerCmd)
		time.sleep(0.1)
		# read slopes into insnR
		device.do_insn(readCmd)
		dat = readCmd.data

		slopeZero = getSlopes(dat, fracBits)
		# store slope individually in variables
		
		slopeXZero = slopeXZero + _numpy.uint32( slopeZero.slopeX )
		slopeYZero = slopeYZero + _numpy.uint32( slopeZero.slopeY )
		
	slopeXZero = _numpy.uint32(slopeXZero/nbRepeats)
	slopeYZero = _numpy.uint32(slopeYZero/nbRepeats)
	
	ret = getInfluenceFct_mirrorSettings.MySlopes( slopeX = slopeXZero, slopeY = slopeYZero )

	return ret

def getSlopes( data, fracBits ):
	_slopeX = list(data)
	_slopeY = list(data)
	#vhex = _numpy.vectorize(hex)
	#print vhex(data)
	
	if fracBits == "8":
		mask = _numpy.uint32(0x0000ffff)
	else:
		mask = _numpy.uint32(0x00000fff)
			
	for l in range(len(_slopeX)):
		_slopeX[l] =  _numpy.uint32(_slopeX[l] & mask)
		_slopeY[l] = _numpy.uint32((_numpy.uint32(_slopeY[l]) >> 16 ) & mask)

	ret = getInfluenceFct_mirrorSettings.MySlopes( slopeX = _slopeX, slopeY = _slopeY )

	return ret


def saveData( time, data, slopeZero, slopeZero2, data_ref, activateZeroSlopes, log, hadamard ):

	_log = log.getvalue()

	print "PLEASE be patient, file is getting saved to disk."
	str = "dataInfluenceFctMatrix_" + time.strftime("%Y-%m-%d_%H-%M") + ".mat"
	cnt = 0;
	while _os_path.exists( str ):
		str = "dataInfluenceFctMatrix_" + time.strftime("%Y-%m-%d_%H-%M") + "__%s.mat" % cnt
		cnt = cnt + 1;

	sio.savemat(str, {'data': data, 'slopeZero':slopeZero,  'slopeZero2':slopeZero2,
	  'activateZeroSlopes':activateZeroSlopes, 'hadamardMat':hadamard, 'log': _log,
	  'data_ref':data_ref }, oned_as='row')

	print "finished saving .mat file to disk, filename is "+str+"!\n\n"
