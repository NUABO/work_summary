#!/usr/bin/env python
# coding=utf-8

#encrypt.py

import os
import sys
from struct import *



def compose(file_out):
    size = 1024
    f_out = open(file_out,'wb')
    if os.path.isdir("decompose"):
        os.chdir("./decompose")
    else:
        print "no dir decompose"
        return
    file_list = os.listdir("./")
    file_list.sort()
    for filename in file_list:
        f_in = open(filename,"rb")
        s = f_in.read()
        f_out.write(s)
        f_in.close()
    f_out.close()

def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    if len(sys.argv)<2:
        print """input the filename """
        return
    compose(sys.argv[1])




if __name__ == "__main__":
    sys.exit(main())

