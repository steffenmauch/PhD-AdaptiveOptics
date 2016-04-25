#!/usr/bin/env python
#
# Copyright (C) 2014/2015 Steffen Mauch <steffen.mauch (at) unorthodox-solutions.de>
#
# $Id: getInfluenceFct.py 1822 2015-08-07 14:45:38Z smauch $
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

from getInfluenceFct_general import *
import getopt, sys

import getInfluenceFct_standard
import getInfluenceFct_hadamard

from pycomedi.device import Device as _device
from pycomedi import channel as _channel
from pycomedi import constant as _constant
from pycomedi import utility as _utility
from pycomedi.chanspec import ChanSpec as _chanSpec

svnid = '$Id: getInfluenceFct.py 1822 2015-08-07 14:45:38Z smauch $'

if __name__ == '__main__':

	helpStr = './run --type <standard/hadamard> --fracBits <4/8>';
	type = "standard"
	fracBits = "4"
	try:
		opts, args = getopt.getopt(sys.argv[1:],"hm:s",["type=","fracBits="])
	except getopt.GetoptError:
		print helpStr
		exit(2)
	
	for opt, arg in opts:
		if opt == '-h':
			print helpStr
			exit()
		elif opt in ("--type"):
			if arg == "hadamard":
				type = "hadamard"
			elif arg == "standard":
				type = "standard"
			else:
				print helpStr
				exit()
		elif opt in ("--fracBits"):
			if arg == "4":
				fracBits = "4"
			elif arg == "8":
				fracBits = "8"
			else:
				print helpStr
				exit()

	activateZeroSlopes = True
	#activateZeroSlopes = False

	# use this setup for deformable mirror STE - with 24 actuators
	#ret = getInfluenceFct_mirrorSettings.mirrorSTE_24Act()
	
	# use this setup for deformable mirror STE - with 40 actuators
	ret = getInfluenceFct_mirrorSettings.mirrorSTE_40Act()
	
	# use this setup for tipTilt mirror
	#ret = getInfluenceFct_mirrorSettings.tiptTilt()
	
	repeatMeas = 6
	
	ret.log.write("_nbOfRepeats:\n%s\n" % ( str(repeatMeas) ))
	ret.log.write("_mainFileVersion:\n%s\n" % ( svnid ))
	ret.log.write("_fracBitsSHWFS:\n%s\n" % ( fracBits ))
	ret.log.write("_mainFile:\n%s\n" % ( type ))
	ret.log.write("_mainFileGeneral:\n%s\n" % ( svnidGeneral ))

	assert (ret.maxVolt+ret.defaultVolt) < 2**16, "maxVolt + defaultVolt must be smaller 2**16"

	if type == "hadamard" :
		print "\n  using hadamard scheme \n"
		ret.log.write("_typeFile:\n%s\n" % ( getInfluenceFct_hadamard.svnid ))
		getInfluenceFct_hadamard.run(ret.defaultVolt, ret.maxVolt, ret.offsetChannel, 
		 ret.listChannels, ret.orderChannel, activateZeroSlopes, ret.log, repeatMeas, fracBits)
	else:
		print "\n  using standard scheme \n"
		ret.log.write("_typeFile:\n%s\n" % ( getInfluenceFct_standard.svnid ))
		getInfluenceFct_standard.run(ret.defaultVolt, ret.maxVolt, ret.offsetChannel, 
		 ret.listChannels, ret.orderChannel, activateZeroSlopes, ret.log, repeatMeas, fracBits)

	#print ret.log.getvalue()
