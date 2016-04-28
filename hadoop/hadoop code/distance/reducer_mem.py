#!/usr/bin/env python
# coding=utf-8

from operator import itemgetter
import sys
import os
import time
import numpy as np

vector_n = 100 

def euclDistance(vector1, vector2):
    #time.sleep(1)
    return np.sqrt(np.sum(np.power(vector2 - vector1, 2)))

#print "start reducer :%s" % time.ctime()
# input comes from STDIN


def count_time(func):
    def func_time():
        with open("/root/hadoop_out_mem.txt","a") as f:
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
    """
    这个版本的reducer也不好，因为要不断从memcache服务器中取vaule，当数目为N时，需要取N*N/2次，相当于数据
    放大了N/2陪
    """
    import memcache
    mc = memcache.Client(['191.168.45.74:11211',  '191.168.45.104:11211'], debug=0)
    for line in sys.stdin:
        try:
            # remove leading and trailing whitespace
            line = line.strip()
            #print line
        
            # parse the input we got from mapper.py
            key = line.split('\t', 1)[0]
            data = mc.get(key)
            key = int(key)
            vector1 = np.array(map(int,data.strip().split('#')), np.int32)
            for i in range(key, vector_n):
                data = mc.get(str(i))
                vector2 = np.array(map(int,data.strip().split('#')), np.int32)
                print '(%d,%d): %f' % (key, i, euclDistance(vector1, vector2))

        except BaseException ,err:
            print  "ERROR:",err

if __name__ == "__main__":
    sys.exit(reducer())
        


