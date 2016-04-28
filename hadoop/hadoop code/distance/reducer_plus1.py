#!/usr/bin/env python
# coding=utf-8

from operator import itemgetter
import sys
import os
import time
import numpy as np

vector_d = 1000000  #向量的维度
vector_n = 100 #向量数目

split_num = 100

def euclDistance(vector1, vector2):
    #time.sleep(1)
    return np.sum(np.power(vector2 - vector1, 2))

#print "start reducer :%s" % time.ctime()
# input comes from STDIN

def count_time(func):
    def func_time():
        with open("/root/hadoop_out_plus.txt","a") as f:
            s = "reducer : pid %d\n" % os.getpid()
            start_time = time.time()
            s = s + "[%s] %s start called\n" % (time.ctime(),func.__name__)
            ret = func()
            end_time = time.time()
            s = s + "[%s] %s end called\n" % (time.ctime(),func.__name__)
            s = s + "call %s use time : %s\n\n\n" %(func.__name__, end_time - start_time)
            f.write(s)
        return ret
    return func_time

@count_time
def reducer():
    current_key = None
    current_data = None
    array = None
    try:
        for line in sys.stdin:
            
                # remove leading and trailing whitespace
                line = line.strip()
                #print line
            
                # parse the input we got from mapper.py
                key, index, data = line.split('\t')
                data = data.strip().split('#')
                #print key ,data
             
                # this IF-switch only works because Hadoop sorts map output
                # by key (here: word) before it is passed to the reducer
                if current_key == key:
                    array[int(index)] = (map(int, data))
                else:
                    if array == None:
                        array = np.zeros((vector_n, len(data)),np.int32)
                    else:
                        for index1 in range(vector_n):
                            for index2 in range(index1,vector_n):
                                dictace = euclDistance(array[index1], array[index2])
                                print "(%d,%d)\t%d" %(index1, index2, dictace)
                    array[int(index)] = (map(int, data))
                    current_key = key
                    current_data = data
        for index1 in range(vector_n):
                for index2 in range(index1,vector_n):
                    distance = euclDistance(array[index1], array[index2])
                    print "(%d,%d)\t%d" %(index1, index2, distance)
    except BaseException ,err:
        print  "ERROR:",err

if __name__ == "__main__":
    sys.exit(reducer())
        


