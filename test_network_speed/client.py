#!/usr/bin/env python

from socket import *

import time
import argparse
import sys
import os





USAGE = """%s [options]

"""

        

class Client():
    """
    """
    
    def __init__(self, args):
        """
        """
        self.server = args.server
        self.port = args.port
        if "K" in args.block or "k" in args.block:
            self.block = int(args.block[:-1])*1024
        elif "M" in args.block or "m" in args.block:
            self.block = int(args.block[:-1])*1024*1024
        else:
            print "block size : %s is error" % args.block
        if "K" in args.filesize or "k" in args.filesize:
            self.filesize = int(args.filesize[:-1])*1024
        elif "M" in args.filesize or "m" in args.filesize:
            self.filesize = int(args.filesize[:-1])*1024*1024
        elif "G" in args.filesize or "g" in args.filesize:
            self.filesize = int(args.filesize[:-1])*1024*1024*1024
        else:
            print "file size : %s is error" % args.filesize
        
    def _main(self):
        """
        """
        ADDR = (self.server, self.port)
        tcpCliSock = socket(AF_INET, SOCK_STREAM)
        tcpCliSock.connect(ADDR)
        data = "1"*self.block
        size = 0
        starttime = time.time()
        while size <= self.filesize:
            tcpCliSock.send(data)
            size =size + self.block
        endtime = time.time()
        tcpCliSock.close()
        print "write %f KB/s" % (size/(endtime - starttime)/1024.0)
 


def main():
    parser = argparse.ArgumentParser(usage=USAGE)
    parser.add_argument('-s', '--server', metavar="ADDRESS",
            default="127.0.0.1", help='The address of  server')
    parser.add_argument('-p', '--port',type=int, default=2015,
            help='The port of  server')
    parser.add_argument('-b', '--block', metavar="*K,*M",
            default="1k", help='block size.')
    parser.add_argument('-f', '--filesize', metavar="*K,*M,*G",
            default="3k", help='filesize size.')

    args = sys.argv[1:]
    opts = parser.parse_args(args)
    client = Client(opts)
    client._main()



    
if __name__ == "__main__":
    sys.exit(main())  







