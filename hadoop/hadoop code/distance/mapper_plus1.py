#!/usr/bin/env python
# coding=utf-8

import sys
import os
import time

vector_d = 1000000  #向量的维度
vector_n = 100 #向量数目

split_num = 100

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
        
        index, data = line.strip().split("\t")
        data = data.strip().split("#")
        index = int(index)
        length = vector_d/split_num
        for i in range(0, vector_d, length):
            # write the results to STDOUT (standard output);
            # what we output here will be the input for the
            # Reduce step, i.e. the input for reducer.py
            #
            # tab-delimited; the trivial word count is 1
            data_s = "#".join(data[i:i+length])
            print '%d\t%d\t%s' % (i, index, data_s)             

            
if __name__ == "__main__":
    sys.exit(mapper())