#!/usr/bin/env python
# coding=utf-8

from socket import *

import time
import argparse
import sys
import os
import threading


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
        self.server = args.server
        self.port = args.port
        self.number = args.number/args.thread
        self.thread = args.thread
        self.index = index
        self.client = args.client.split(",")
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
        
    def _main(self):
        """
        """
        global starttime
        global endtime
        global finish
        global all_num
        #global con
        ADDR = (self.server, self.port)
        c_num = 0
        CliSock = []
        if self.index == 0 :
            starttime = time.time()
        for c_addr in self.client:
            for c_port in range(1025+self.index, 65535, self.thread):
                tcpCliSock = socket(AF_INET, SOCK_STREAM)
                try:
                    #before bind
                    tcpCliSock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
                    tcpCliSock.bind((c_addr, c_port))
                    tcpCliSock.connect(ADDR)
                    CliSock.append(tcpCliSock)
                    c_num =c_num +1
                    if c_num >= self.number:
                        break
                except:
                    tcpCliSock.close()
            if c_num >= self.number:
                break
        
        while True:
            if con.acquire():
                finish = finish + 1
                all_num = all_num + c_num
                if finish < self.thread:
                    con.wait()
                    con.release()
                    break
                else:
                    finish = 0 
                    print "connect num ", all_num
                    endtime = time.time()
                    print "time: ", (endtime - starttime)
                    raw_input("input everything to continue:")
                    con.notifyAll()
                    con.release()
                    break
           
        if self.index == 0 :
            starttime = time.time()
        data = "1"*self.block
        size = 0
        while size < self.filesize:
            for tcpCliSock in CliSock:
                tcpCliSock.send(data)
            size =size + self.block
        for tcpCliSock in CliSock:
            tcpCliSock.shutdown(SHUT_WR)
            
        while True:
            if con.acquire():
                finish = finish + 1 
                if finish < self.thread:
                    con.wait()
                    # wait返回后又获得了锁，退出前要释放
                    con.release()
                    break
                else: 
                    finish = 0
                    endtime = time.time()
                    print "time: ", (endtime - starttime)
                    print "write %f KB/s" % (size*all_num/(endtime - starttime)/1024.0)
                    #raw_input("input everything to continue:")
                    con.notifyAll()
                    # notifyAll返回后还是获得了锁，退出前要释放
                    con.release()
                    break
        

 

def thread_fun(opts, index):
    client = Client(opts, index)
    client._main()

def main():
    parser = argparse.ArgumentParser(usage=USAGE)
    parser.add_argument('-s', '--server', metavar="ADDRESS",
            default="127.0.0.1", help='The address of  server')
    parser.add_argument('-p', '--port',type=int, default=2015,
            help='The port of  server')
    parser.add_argument('-c', '--client',metavar="ADDR1,ADDR2",
                        default="",help='The address of client')
    parser.add_argument('-n', '--number',type=int, default=1,
                        help='number of connection')
    parser.add_argument('-b', '--block', metavar="*B,*K,*M",
            default="1k", help='block size.')
    parser.add_argument('-f', '--filesize', metavar="*B,*K,*M,*G",
            default="3k", help='filesize size.')
    parser.add_argument('-t', '--thread', type=int, default=1,
             help='thread number.')
    
    
    

    args = sys.argv[1:]
    opts = parser.parse_args(args)
    
    os.system('echo "1024 65535" >>/proc/sys/net/ipv4/ip_local_port_range ')
    os.system('echo "1001000" >>/proc/sys/fs/file-max ')
    # vi /etc/rc.local  ulimit -n 1001000
    # 或者在运行脚本前运行 ulimit -n 1001000
    #os.system('ulimit -n 1001000')
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







