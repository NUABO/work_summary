#!/usr/bin/env python
# coding=utf-8

#encrypt.py

import os
import sys
from struct import *



def encrypt(file_in, file_out):
    key = 0xa5
    filesize = os.path.getsize(file_in)
    f_in = open(file_in,'rb')
    f_out = open(file_out,'wb')
    for i in range(filesize):
        #data_id = struct.unpack("c", f_in.read(1))
        s = f_in.read(1)
        s = (ord(s))^key
        f_out.write(chr(s))
    f_in.close()
    f_out.close()
        



def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    if len(sys.argv)<3:
        print """input the filename and  encrypt filename"""
        return
    encrypt(sys.argv[1], sys.argv[2])




if __name__ == "__main__":
    sys.exit(main())

