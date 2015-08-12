#!/usr/bin/env python
# coding=utf-8


from socket import *
s = socket(AF_INET, SOCK_STREAM)
s.getsockopt(SOL_TCP,SO_RCVBUF)
s.getsockopt(SOL_TCP,TCP_MAXSEG)
#设置不知要怎么才生效