#!/usr/bin/env python
from operator import itemgetter
import sys
import os
import time
import numpy as np

def euclDistance(vector1, vector2):
    #time.sleep(1)
    return np.sqrt(np.sum(np.power(vector2 - vector1, 2)))

#print "start reducer :%s" % time.ctime()
# input comes from STDIN

def count_time(func):
    def func_time():
        with open("/root/hadoop_out.txt","a") as f:
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
    for line in sys.stdin:
        try:
            # remove leading and trailing whitespace
            line = line.strip()
            #print line
        
            # parse the input we got from mapper.py
            key, data = line.split('\t', 1)
            #print key ,data
         
            # this IF-switch only works because Hadoop sorts map output
            # by key (here: word) before it is passed to the reducer
            if current_key == key:
                vector1 = np.array(map(int,current_data.strip().split('#')), np.int32)
                vector2 = np.array(map(int,data.strip().split('#')), np.int32)
                print '%s: %f' % (current_key, euclDistance(vector1, vector2))
            else:
                current_key = key
                current_data = data
        except BaseException ,err:
            print  "ERROR:",err

if __name__ == "__main__":
    sys.exit(reducer())
        


