#!/usr/bin/env python
# coding=utf-8

import sys
import os
import time

vector_n = 100 #向量数目

def count_time(func):
    def func_time():
        with open("/root/hadoop_out.txt","a") as f:
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
        
        index, data = line.strip().split("\t")
        index = int(index)
        for i in range(vector_n):
            # write the results to STDOUT (standard output);
            # what we output here will be the input for the
            # Reduce step, i.e. the input for reducer.py
            #
            # tab-delimited; the trivial word count is 1
            if i < index :
                print '(%d,%d)\t%s' % (i, index, data)
            elif i> index :
                print '(%d,%d)\t%s' % (index, i, data)
            else :
                print '(%d,%d)\t%s' % (index, i, data)
                print '(%d,%d)\t%s' % (index, i, data)             

            
if __name__ == "__main__":
    sys.exit(mapper())