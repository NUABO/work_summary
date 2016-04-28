#!/usr/bin/env python
# coding=utf-8

#print_xattr.py

import os
import sys
import re
import subprocess




def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    #if len(sys.argv)<2 or '-h' in sys.argv:
    if  len(sys.argv) == 6:
        print """[osd.%s]
public addr = %s
cluster addr = %s
host = %s
devs = %s

""" % (sys.argv[1], sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5])
    else:
        print """[osd.%s]
public addr = %s
cluster addr = %s
host = %s
devs = %s
jour_devs = %s

""" % (sys.argv[1], sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6])
	




if __name__ == "__main__":
    sys.exit(main())
