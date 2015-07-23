#!/usr/bin/env python

from socket import *

HOST = 'localhost'
PORT = 2015
BUFSIZ = 1024
ADDR = (HOST, PORT)

tcpCliSock = socket(AF_INET, SOCK_STREAM)
tcpCliSock.connect(ADDR)
while True:
    data = raw_input('> ')
    if not data:
        break
    if data == "close":
        tcpCliSock.close()
    else:
        tcpCliSock.send('%s' % data)
    #data = tcpCliSock.recv(BUFSIZ)
    #if not data:
    #    break
    #print data.strip()
    #tcpCliSock.close()
