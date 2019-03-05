#!/usr/bin/env python
# coding=utf-8

#print_xattr.py

import commands
import os
import os.path
import sys
from struct import *

ignoreFile = ["changeMd5.py"]

def change_md5(filename):
    if os.path.basename(filename) in ignoreFile:
        return
    filesize = os.path.getsize(filename)
    if filesize == 0:
        return
    f_in = open(filename,'rb')
    s = f_in.read(filesize)
    num = ord(s[filesize-1])+1
    if num > 255:
        num = 0
    s_new = s[:filesize-1] + chr(0)
    f_in.close()
    f_out = open(filename,'wb')
    f_out.write(s_new)
    f_out.close()

def change_md5_all(directory):
    if os.path.isdir(directory):
        file_list = os.listdir(directory)
        file_list.sort()
        for filename in file_list:
            if filename[0] == '.':
                continue
            filename = os.path.join(directory, filename)
            if os.path.isdir(filename):
                change_md5_all(filename)
            else:
				change_md5(filename)


def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    if len(sys.argv) < 2:
        dir = os.getcwd()
    else:
        dir = sys.argv[1]
    print "dir: ",dir
    change_md5_all(dir)




if __name__ == "__main__":
    sys.exit(main())


