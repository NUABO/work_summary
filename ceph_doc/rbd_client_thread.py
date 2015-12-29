#!/usr/bin/env python
# coding=utf-8

from socket import *

import time
import argparse
import sys
import os
import threading
import rados
import rbd


finish = 0
con = threading.Condition()
starttime = 0
endtime = 0
all_num = 0


USAGE = """%s [options]

"""

        

class Client():
    """
    """
    
    def __init__(self, args, index):
        """
        """
        self.pool = args.pool
        self.image = args.image
        self.thread = args.thread
        self.index = index
        if "B" in args.block or "b" in args.block:
            self.block = int(args.block[:-1])
        elif "K" in args.block or "k" in args.block:
            self.block = int(args.block[:-1])*1024
        elif "M" in args.block or "m" in args.block:
            self.block = int(args.block[:-1])*1024*1024
        else:
            print "block size : %s is error" % args.block
        if "B" in args.filesize or "b" in args.filesize:
            self.filesize = int(args.filesize[:-1])
        elif "K" in args.filesize or "k" in args.filesize:
            self.filesize = int(args.filesize[:-1])*1024
        elif "M" in args.filesize or "m" in args.filesize:
            self.filesize = int(args.filesize[:-1])*1024*1024
        elif "G" in args.filesize or "g" in args.filesize:
            self.filesize = int(args.filesize[:-1])*1024*1024*1024
        else:
            print "file size : %s is error" % args.filesize
        
        if "B" in args.offset or "b" in args.offset:
            self.offset = int(args.offset[:-1])
        elif "K" in args.offset or "k" in args.offset:
            self.offset = int(args.offset[:-1])*1024
        elif "M" in args.offset or "m" in args.offset:
            self.offset = int(args.offset[:-1])*1024*1024
        elif "G" in args.offset or "g" in args.offset:
            self.offset = int(args.offset[:-1])*1024*1024*1024
        else:
            print "file size : %s is error" % args.offset
        
    def _main(self):
        """
        """
        global starttime
        global endtime
        global finish

        if self.index == 0 :
            starttime = time.time()
        offset = self.filesize/self.thread*self.index + self.offset
        with rados.Rados(conffile='/etc/ceph/ceph.conf') as cluster:
            with cluster.open_ioctx(self.pool) as ioctx:
                rbd_inst = rbd.RBD()
                with rbd.Image(ioctx, self.image) as image:
                    data = '1' *  self.block
                    for i in range(self.filesize/self.thread/self.block):
                        image.write(data, offset)
                        offset = offset + self.block
                        
        
        while True:
            if con.acquire():
                finish = finish + 1
                if finish < self.thread:
                    con.wait()
                    con.release()
                    break
                else:
                    finish = 0 
                    endtime = time.time()
                    print "time: ", (endtime - starttime)
                    print "speed = %sKB/s " % (self.filesize/(endtime - starttime)/1024)
                    con.notifyAll()
                    con.release()
                    break
           


 

def thread_fun(opts, index):
    client = Client(opts, index)
    client._main()

def main():
    parser = argparse.ArgumentParser(usage=USAGE)
    parser.add_argument('-p', '--pool', 
            default="127.0.0.1", help='The pool name of ceph rbd')
    parser.add_argument('-i', '--image',
                        default="",help='The image name of ceph rbd')
    parser.add_argument('-b', '--block', metavar="*B,*K,*M",
            default="1k", help='block size.')
    parser.add_argument('-o', '--offset', metavar="*B,*K,*M",
            default="0B", help='offset size.')
    parser.add_argument('-f', '--filesize', metavar="*B,*K,*M,*G",
            default="3k", help='filesize size.')
    parser.add_argument('-t', '--thread', type=int, default=1,
             help='thread number.')
    
    
    

    args = sys.argv[1:]
    opts = parser.parse_args(args)
    
    threads = []
    for i in range(opts.thread):
        t=threading.Thread(target=thread_fun,args=(opts, i))
        threads.append(t)
    for i in range(opts.thread):
        threads[i].start()
    for i in range(opts.thread):
        threads[i].join()



    
if __name__ == "__main__":
    sys.exit(main())  







