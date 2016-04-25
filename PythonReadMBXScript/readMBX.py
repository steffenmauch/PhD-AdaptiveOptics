#
# ($Id: readMBX.py 1579 2015-03-08 18:49:25Z smauch $)
#
# copyright by:
# Steffen Mauch, (c) 03/2015
# email: steffen.mauch (at) gmail.com
#

from xml.etree.ElementTree import Element, SubElement, Comment
from ElementTree_pretty import prettify

import sys, getopt
import copy
import ctypes
import numpy as np
import scipy.io as sio
import datetime

from rtai_lxrt import *
from rtai_mbx import *
from rtai_msg import *
from rtai_sem import *

def saveData(dat1,mbxNr):
	print "PLEASE be patient, file is getting saved to disk."
	now = datetime.datetime.now()
	str = "data_" + now.strftime("%Y-%m-%d_%H-%M") + "_mbx{}".format(mbxNr) + ".mat"
	data = dat1[0:j,:]
	sio.savemat(str, {'data': data}, oned_as='row')
	print "finished saving .mat file to disk, filename is "+str+"!\n\n"

class POLL(Structure) :
	_fields_ = [("max", c_int),
		("min", c_int)]
ufds = POLL(0,1)

helpStr = 'readMBX.py --mbx <mbxNumber> --size <sizeOfFrame>';
mbxNr = 0
lengthBlock = 256
try:
	opts, args = getopt.getopt(sys.argv[1:],"hm:s",["mbx=","size="])
except getopt.GetoptError:
	print helpStr
	sys.exit(2)
	
for opt, arg in opts:
	if opt == '-h':
		print helpStr
		sys.exit()
	elif opt in ("-m", "--mbx"):
		if arg.isdigit():
			mbxNr = int(arg)
		else:
			print "mbx must be an integer"
			sys.exit()
	elif opt in ("-s", "--size"):
		if arg.isdigit():
			lengthBlock = int(arg)
		else:
			print "mbx must be an integer"
			sys.exit()
		
#print 'mbxNr is ', mbxNr
#print 'lengthBlock is ', lengthBlock

rt_allow_nonroot_hrt()
task = rt_task_init_schmod(nam2num("LATCHK"), 20, 0, 0, 0, 0xF)
mbxName = "RTL{}".format(mbxNr)
#print mbxName
mbx = rt_get_adr(nam2num( mbxName ))

if mbx == NULL:
	print "mbx does not exist"
	exit(0)

rt_make_hard_real_time()

#lengthBlock = (196*2+1)
read_lengthBlock = lengthBlock*4
read_lengthBlock_bytes = sizeof(c_double)*read_lengthBlock

preAllocSize = 400000;
dat1 = np.zeros((preAllocSize,lengthBlock))
dat2 = [None]*lengthBlock

arrayDouble = (c_double*read_lengthBlock)()

print "\nPRESS [ENTER] to write .mat file and exit the aquiring phase!\n"
j = 0
doLoop = True
while doLoop :
	
	cnt = rt_mbx_receive_if(mbx, arrayDouble, read_lengthBlock_bytes)
	if cnt == 0:
		k = 0
		for i in arrayDouble:
			dat1[j,k] = i
			k = k+1
			
			if k == lengthBlock :
				k = 0;
				j = j+1
				if j>=preAllocSize :
					saveData(dat1,mbxNr)
					doLoop = False
					break
	
	if libc.poll(byref(ufds), 1, 1) :
		ch = libc.getchar()
		#print dat1
		saveData(dat1,mbxNr)
		doLoop = False
		break
	
