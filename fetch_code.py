#!/usr/bin/env python
# coding=utf-8

import argparse
import sys
import os
import copy
import re


USAGE = """%s [options]
example: python fetch_code.py -s /home/zhong/tmp/ceph-9.2.0/src -d /home/test3 -i /home/zhong/tmp/ceph-9.2.0/src/os -c

"""

dir_fetch_cfile = ["src/common", "src/global"]
        

def copy_file(opts, filename):
    dest_file = filename.replace(opts.src, opts.dest)
    if os.path.exists(dest_file):
        return
    if not os.path.exists(os.path.split(dest_file)[0]):
        os.system("mkdir -p %s" % os.path.split(dest_file)[0])
    os.system("/bin/cp -f %s %s" % (filename, dest_file))
    print filename
    f = open(filename, "r")
    fbuffer = f.read()
    f.close()
    inc_files = re.findall("#include \"(.*\.hp*)",fbuffer)
    for f_name in inc_files:
        full_name = os.path.join(opts.src, f_name)
        if not os.path.exists(full_name):
            full_name = os.path.join(os.path.split(filename)[0], f_name)
            if not os.path.exists(full_name):
                print "The file %s is not exits" % f_name
                continue
                
        copy_file(opts, full_name) 
        cfilename = None
        for suf in [".c", '.cc', '.cpp']:
            cfilename = re.sub("\.hp*", suf, full_name)
            if os.path.exists(cfilename):
                break
        
        if  os.path.exists(cfilename):
            if opts.cfile:
                copy_file(opts, cfilename) 
            else:
                for dir1 in dir_fetch_cfile:
                    if dir1 in cfilename:
                        copy_file(opts, cfilename)
                        
                


def copy_file_all(opts):
    if os.path.isdir(opts.input):
        file_list = os.listdir(opts.input)
        file_list.sort()
        for filename in file_list:
            if filename[0] == '.':
                    continue
            filename = os.path.join(opts.input, filename)
            if os.path.isdir(filename):
                opt = copy.deepcopy(opts)
                opt.input = filename
                copy_file_all(opt)
            else:
                copy_file(opts, filename)
    elif os.path.isfile(opts.input):
        copy_file(opts, opts.input)
    else:
        print "%s is not exist." % opts.input

          

def main():
    parser = argparse.ArgumentParser(usage=USAGE)
    parser.add_argument('-s', '--src', 
            default="/home/zhong/ceph-9.2.0/src/", help='The dir of src.')
    parser.add_argument('-d', '--dest',
                        default="/home/Filestore/",help='The dir of dest.')
    parser.add_argument('-i', '--input',default="/home/zhong/ceph-9.2.0/src/os/",
                        help='The dir or file of input.')
    parser.add_argument('-c', '--cfile',action='store_true',
                        help='copy c and cpp file')
    
    
    

    args = sys.argv[1:]
    opts = parser.parse_args(args)
    
    print opts.src,  opts.dest, opts.input, opts.cfile
    
    
    if not os.path.isdir(opts.src):
        print "the src dir is not dir\n"
        exit(0)
            
    if not os.path.isdir(opts.dest):
        print "the dest dir is not dir\n"
        exit(0)
        
        
    if len(os.listdir(opts.dest)) != 0:
        print "the dest dir is not empty\n"
        exit(0)
        
    if opts.src not in opts.input:
        print "the input file is not in dest dir\n"
        exit(0)
        
    copy_file_all(opts)
    
    
    
    
    



    
if __name__ == "__main__":
    sys.exit(main())  







