#!/usr/bin/env python
# coding=utf-8

#print_xattr.py

import xattr
import os
import sys
from struct import *


def print_xattr(filename):
    print filename, " :"
    xattr_tuple = xattr.listxattr(filename)
    for xattr_key in xattr_tuple:
        xattr_value = xattr.getxattr(filename, xattr_key)
        if "-d" not in sys.argv:
            print "%40s : %s" % (xattr_key, repr(xattr_value))
        else:
            #xattr_value_128 = (16-len(xattr_value))*'\x00'+ xattr_value
            #value_128 = unpack('>QQ', xattr_value_128)
            #print "%40s : %s  (%d%d)" % (xattr_key, repr(xattr_value), value_128[0], value_128[1])
            xattr_len = len(xattr_value)
            value_char = unpack('B'*xattr_len, xattr_value)
            #print "%40s : %s  " % (xattr_key, repr(xattr_value)),
            print "%40s : " % xattr_key,
            print "0x"+"%02x"*xattr_len % value_char
    print "\n"


def print_xattr_all(directory):
    if os.path.isdir(directory):
        print_xattr(directory)
        file_list = os.listdir(directory)
        file_list.sort()
        for filename in file_list:
            if "-a" not in sys.argv:
                if filename[0] == '.':
                    continue
            filename = os.path.join(directory, filename)
            if os.path.isdir(filename):
                print_xattr_all(filename)
            else:
                print_xattr(filename)
    elif os.path.isfile(directory):
        print_xattr(directory)
    else:
        print "%s is not exist." % directory



def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    if len(sys.argv)<2:
        print """print_xattr.py <dir1> [dir2] [...] [options]
        -n : no print subdirectory
        -a : print all file,include hidden file
        -d : print hash value in integer """
    if  "-n" in sys.argv:
        for i in range(1,len(sys.argv)):
            if sys.argv[i][0] !='-':
                print_xattr(sys.argv[i])
        return
    for i in range(1,len(sys.argv)):
        if sys.argv[i][0] !='-':
            print_xattr_all(sys.argv[i])




if __name__ == "__main__":
    sys.exit(main())

