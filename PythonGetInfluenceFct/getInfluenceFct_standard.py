#!/usr/bin/env python
#
# Copyright (C) 2014/2015 Steffen Mauch <steffen.mauch (at) unorthodox-solutions.de>
#
# $Id: getInfluenceFct_standard.py 1809 2015-08-06 05:55:48Z smauch $
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

import time
import numpy as _numpy
import StringIO 
import sys

from collections import namedtuple
from datetime import datetime

from getInfluenceFct_general import *

svnid = '$Id: getInfluenceFct_standard.py 1809 2015-08-06 05:55:48Z smauch $'

from pycomedi.device import Device as _device
from pycomedi import channel as _channel
from pycomedi import constant as _constant
from pycomedi import utility as _utility
from pycomedi.chanspec import ChanSpec as _chanSpec

def run( defaultVolt, maxVolt, offsetChannel, listChannels, orderChannel,
	activateZeroSlopes, log, repeatMeas, fracBits):

	# open comedi device
	device = _device(filename='/dev/comedi0')
	device.open()

	ao_subdevice = device.find_subdevice_by_type(
			_constant.SUBDEVICE_TYPE.ao)

	mem_subdevice = device.find_subdevice_by_type(
			_constant.SUBDEVICE_TYPE.memory)

	#print ao_subdevice

	insnR = mem_subdevice.insn()
	insnR2 = mem_subdevice.insn()
	insnR.data = 256*[0]
	insnR2.data = 256*[0]

	insnSHWFSTrigger = [mem_subdevice.insn(), mem_subdevice.insn(), mem_subdevice.insn()]
	insnSHWFSTrigger[0].insn = insnSHWFSTrigger[2].insn = _constant.INSN.gtod
	insnSHWFSTrigger[0].data = insnSHWFSTrigger[2].data = [0, 0]
	insnSHWFSTrigger[1].data = [1]
	insnSHWFSTrigger[1].insn = _constant.INSN.config

	# deactivate repositioning if enabled!
	insnDeactivateRePos = mem_subdevice.insn()
	insnDeactivateRePos.data = [3, 0, 0]
	device.do_insn(insnDeactivateRePos)
	time.sleep(0.1)

	# set selected channels to defaultVoltage
	#print listChannels
	setInsn = setDefaultVoltage( ao_subdevice, offsetChannel, listChannels, defaultVolt )
	device.do_insn(setInsn)
	
	time.sleep(10)
	
	# average slopeZero measurement
	slopeZero = averageMeasurements( device, repeatMeas, insnSHWFSTrigger, insnR, fracBits )
	
	print "-------------------------------"

	# create empty matrix for slopes measured from now on
	shwfsData = _numpy.uint32(_numpy.zeros( (len(orderChannel),2*len(insnR.data)) ))
	shwfsData_ref_previous = _numpy.uint32(_numpy.zeros( (len(orderChannel),2*len(insnR.data)) ))
	#print shwfsData.shape

	insnsW = ao_subdevice.insn()
	insnsW.insn = _constant.INSN.write
	kk = True
	while kk == True:
		for k in range( len(orderChannel) ):
			insnsW.chanspec = _chanSpec(chan=orderChannel[k], range=0, aref=0)

			time.sleep(1)
			# average zeroSlopes for each act
			ret2 = averageMeasurements( device, repeatMeas, insnSHWFSTrigger, insnR, fracBits )

			for l in range(0,11):

				insnsW.data = [ _numpy.floor( defaultVolt+maxVolt/10*l ) ]
				device.do_insn(insnsW)
				# wait 50 ms
				time.sleep(0.05)

			time.sleep(1)
			
			# average max slope for act
			slope = averageMeasurements( device, repeatMeas, insnSHWFSTrigger, insnR, fracBits )
			slopeX = slope.slopeX
			slopeY = slope.slopeY
	
			if activateZeroSlopes == True:
				shwfsData_ref_previous[k,:] = _numpy.append(_numpy.uint32(ret2.slopeX),_numpy.uint32(ret2.slopeY))
				print " activateZeroSlopes true"

			#vhex = _numpy.vectorize(hex)
			#print vhex(insnR.data)
			#print vhex(slopeX)
			#print vhex(slopeY)
			print " captured wavefront"
			# store captured slope data into matrix
			shwfsData[k,:] = _numpy.append(slopeX,slopeY)

			for l in reversed(range(0,11)):

				insnsW.data = [ _numpy.floor( defaultVolt+maxVolt/10*l ) ]
				device.do_insn(insnsW)
				# wait 50 ms
				time.sleep(0.05)

			print "deflected actuator nb.: "+"%d" % k+" - output %d"%orderChannel[k]

			kk = False

	print "-------------------------------"

	time.sleep(1)

	# average slopeZero2 measurement
	slopeZero2 = averageMeasurements( device, repeatMeas, insnSHWFSTrigger, insnR, fracBits )

	# set previous selected channels to zero volt
	clearInsn = setDefaultVoltage( ao_subdevice, offsetChannel, listChannels, 0)
	device.do_insn(clearInsn)


	timeD = datetime.now()

	c = ao_subdevice.channel(index=0)
	chanVolt = c.get_range(index=0)

	log.write("_comediVoltMin:\n%s\n" % ( chanVolt.min ))
	log.write("_comediVoltMax:\n%s\n" % ( chanVolt.max ))
	log.write("_time:\n%s\n" % ( timeD.strftime("%Y-%m-%d_%H-%M") ) )

	# close comedi device
	device.close()

	#print(shwfsData)
	hadamardMat = []
	saveData( time, shwfsData, slopeZero, slopeZero2, shwfsData_ref_previous, activateZeroSlopes, log, hadamardMat )
