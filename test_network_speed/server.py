#!/usr/bin/env python
# coding=utf-8

import time
import argparse
import sys
import os
from SocketServer import (ThreadingTCPServer as TCP,
    BaseRequestHandler as SRH)




USAGE = """%s [options]

"""


class MyRequestHandler(SRH):
    """
        TCP服务器注册的类，主要包含接收到消息的处理函数
    """
       
    def handle(self):
        """
            接收到消息后的处理函数
        """
        print '...connected from:', self.client_address
        #buf = self.rfile.readlines()
        #print buf
        #print "\n"
        while True:
            #阻塞在这里
            buf = self.request.recv(1024*1024)
			print buf
            #print "buf" ,repr(buf)
            if not buf: #客户端终止或close 都会受到"" 空串
                print "return"
                break

        

class Server():
    """
    """
    
    def __init__(self, args):
        """
        """
        self.port = args.port
        
    def _server(self):
        """
            进程服务入口函数
        """
        host= ''
        ADDR = (host, self.port)
        TCP.allow_reuse_address = True
        tcpServ = TCP(ADDR, MyRequestHandler)
        print 'waiting for connection...'
        tcpServ.serve_forever()
 


def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=49979)
    parser = argparse.ArgumentParser(usage=USAGE)
    parser.add_argument('-p', '--port',type=int, default=2015,
            help='The port of  server')

    args = sys.argv[1:]
    opts = parser.parse_args(args)
    server = Server(opts)
    server._server()



    
if __name__ == "__main__":
    sys.exit(main())  
    
    