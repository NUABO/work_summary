#!/usr/bin/env python
# coding=utf-8

#encrypt.py

import os
import sys
from struct import *



def decompose(file_in):
    size = 1024*100
    filesize = os.path.getsize(file_in)
    f_in = open(file_in,'rb')
    j=0
    os.system("rm -rf decompose")
    os.system("mkdir decompose")
    os.chdir("./decompose")
    for i in range(0,filesize,size):
        j=j+1
        s = f_in.read(size)
        file_out = "%04d" % j
        f_out = open(file_out,'wb')
        f_out.write(s)
        f_out.close()
    f_in.close()
    
        



def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    if len(sys.argv)<2:
        print """input the filename """
        return
    decompose(sys.argv[1])




if __name__ == "__main__":
    sys.exit(main())

