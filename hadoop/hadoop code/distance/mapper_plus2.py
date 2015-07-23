#!/usr/bin/env python
# coding=utf-8

import sys
import os
import time

def count_time(func):
    def func_time():
        with open("/root/hadoop_out_plus.txt","a") as f:
            s = "mapper : pid %d\n" % os.getpid()
            start_time = time.time()
            s = s + "[%s] %s start called\n" % (time.ctime(),func.__name__)
            ret = func()
            end_time = time.time()
            s = s + "[%s] %s end called\n" % (time.ctime(),func.__name__)
            s = s + "call %s use time : %s\n\n\n" %(func.__name__, end_time - start_time)
            f.write(s)
        return ret
    return func_time

# input comes from STDIN (standard input)
@count_time
def mapper():
    for line in sys.stdin:
        print line           

            
if __name__ == "__main__":
    sys.exit(mapper())