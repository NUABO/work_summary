#!/usr/bin/env python
# coding=utf-8

#print_xattr.py

import xattr
import os
import sys
import codecs
import re


def ReadFile(filePath,encoding="utf-8"):
    with codecs.open(filePath,"r",encoding) as f:
        return f.read()
 
def WriteFile(filePath,u,encoding="gbk"):
    with codecs.open(filePath,"wb",encoding) as f:
        f.write(u)
        
def WriteFile2(filePath,u,encoding="gbk"):
    with codecs.open(filePath,"wb") as f:
        f.write(u.encode(encoding,errors="ignore"))
 
def UTF8_2_GBK(src,dst):
    content = ReadFile(src,encoding="utf-8")
    WriteFile2(dst,content,encoding="gbk")
    
def UTF8_2_GB18030(src,dst):
    content = ReadFile(src,encoding="utf-8")
    WriteFile(dst,content,encoding="gb18030")

def cov_code(filename):
    #.c 和 .h 结尾的文件
    if re.match(".*\.[c,h]",filename):
        UTF8_2_GB18030(filename,filename)
        print "cov file %s success" % filename


def cov_code_all(directory):
    if os.path.isdir(directory):
        file_list = os.listdir(directory)
        file_list.sort()
        for filename in file_list:
            if "-a" not in sys.argv:
                if filename[0] == '.':
                    continue
            filename = os.path.join(directory, filename)
            if os.path.isdir(filename):
                cov_code_all(filename)
            else:
                cov_code(filename)
    elif os.path.isfile(directory):
        cov_code(directory)
    else:
        print "%s is not exist." % directory



def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    if len(sys.argv)<2:
        print """cov_code.py <dir1> [dir2] [...] """
    
    for i in range(1,len(sys.argv)):
        if sys.argv[i][0] !='-':
            cov_code_all(sys.argv[i])




if __name__ == "__main__":
    sys.exit(main())

