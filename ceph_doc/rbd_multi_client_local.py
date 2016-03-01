#!/usr/bin/env python
# coding=utf-8

from socket import *

import time
import argparse
import sys
import os
import subprocess
import re



USAGE = """%s [options]
eg: python rbd_multi_client_local.py -p rep-pool -i volume-1 -b 4M -f 1 -c 40
"""
          
          

def main():
    parser = argparse.ArgumentParser(usage=USAGE)
    parser.add_argument('-p', '--pool', 
            default="127.0.0.1", help='The pool name of ceph rbd')
    parser.add_argument('-i', '--image',
                        default="",help='The image name of ceph rbd')
    parser.add_argument('-b', '--block', metavar="*B,*K,*M",
            default="1k", help='block size.')
    parser.add_argument('-c', '--client', type=int,
            default="2", help='client number.')
    parser.add_argument('-o', '--offset', type=int,
            default="0", help='offset size.')
    parser.add_argument('-f', '--filesize', type=int,
            default="10", help='filesize size.')
    
    
    
    args = sys.argv[1:]
    opts = parser.parse_args(args)
    cmd = []
    for i in range(opts.client):
        #cmd1="/home/rbd_client -p %s -i %s -b %s -f %dG -o %dG" % (opts.pool, opts.image, opts.block, opts.filesize, opts.offset + i*opts.filesize)
        cmd1="python /root/rbd_client.py -p %s -i %s -b %s -f %dG -o %dG" % (opts.pool, opts.image, opts.block, opts.filesize, opts.offset + i*opts.filesize)
        cmd.append(cmd1)
    process = []
    for i in range(len(cmd)):     
        p1 = subprocess.Popen(cmd[i], shell=True, stderr=subprocess.STDOUT,
                          stdout=subprocess.PIPE)
        process.append(p1)
    
    for i in range(len(process)):
        process[i].wait()
    all_speed = 0.0
    all_time = []   
    for i in range(len(process)):
        data = process[i].stdout.readlines()
        try:
            m = re.match("speed = (.*)KB/s",data[1])
            all_speed  = all_speed + float(m.groups()[0])
            m = re.match("time:  ([0-9\.]*)",data[0])
            all_time.append(float(m.groups()[0]))
        except:
            pass
        print "".join(data)
    print "max_time = %f" % max(all_time)
    print "sum_time = %f" % sum(all_time)
    print "speed_sum = %fKB/s" % all_speed
    print "speed_max_time = %fKB/s" % (opts.filesize*1024*1024 * len(all_time) / max(all_time))
    print "speed_avg_time = %fKB/s" % (opts.filesize*1024*1024 * len(all_time) / (sum(all_time)/len(all_time)))
    



    
if __name__ == "__main__":
    sys.exit(main())  










