#!/usr/bin/env python
# coding=utf-8

import os
import sys
import time
import subprocess
import numpy as np
import random

vector_d = 1000  #向量的维度
vector_n = 100 #向量数目

def count_time(func):
    def func_time():
        start_time = time.time()
        print "[%s] %s start called" % (time.ctime(),func.__name__)
        ret = func()
        end_time = time.time()
        print "[%s] %s end called" % (time.ctime(),func.__name__)
        print "call %s use time : %s" %(func.__name__, end_time - start_time)
        return ret
    return func_time


@count_time
def new_data():
    with open("data.txt","w+") as f:
        for n in range(vector_n):
            List =[]
            for d in range(vector_d):
                List.append(random.randint(-100, 100))
            s = "#".join(map(str, List))
            f.write(("%d\t%s\n")%(n,s))
@count_time
def distance():
    array = np.zeros((vector_n, vector_d),np.int32)
    i = 0
    with open("data.txt","r") as f:
        for line in f :
            lineArr = line.strip().split('\t')[1].split('#')
            array[i] = (map(int, lineArr))
            i = i + 1
    #print array.nbytes
    #print time.ctime()
 
    with open("distance.txt","w+") as f:
        for index1 in range(vector_n):
            for index2 in range(index1,vector_n):
                distance = euclDistance(array[index1], array[index2])
                f.write("(%d,%d): %f\n" %(index1, index2, distance))
@count_time
def loadData():
    import memcache
    mc = memcache.Client(['191.168.45.74:11211',  '191.168.45.104:11211'], debug=1)
    with open("data.txt","r") as f:
        for line in f :
            key, data = line.strip().split('\t')
            if not mc.set(key, data):
                print "memcache set the the value error"
                sys.exit()
    #print time.ctime()
    #for i in range(vector_n):
    #    for j in range(i, vector_n):
    #        data = mc.get(str(j))
    #print time.ctime()
    #for i in range(vector_n):
    #    mc.delete(str(i))
    #    data = mc.get(str(i))
    #print time.ctime()
    #sys.exit()


@count_time
def distance_hadoop():
    cmd = """
    hadoop jar /opt/hadoop-2.7.0/share/hadoop/tools/lib/hadoop-streaming-2.7.0.jar \
    -D mapred.reduce.tasks=8 \
    -input /data  -output /distance_output \
    -mapper /opt/hadoop-2.7.0/hadoop_code/distance/mapper.py \
    -file /opt/hadoop-2.7.0/hadoop_code/distance/mapper.py \
    -reducer /opt/hadoop-2.7.0/hadoop_code/distance/reducer.py \
    -file /opt/hadoop-2.7.0/hadoop_code/distance/reducer.py \
    >>hadoop.out 2>&1
    """
    os.system(cmd)
@count_time
def distance_hadoop_mem():
    """
    use memcached 
    """
    loadData()
    cmd = """
    hadoop jar /opt/hadoop-2.7.0/share/hadoop/tools/lib/hadoop-streaming-2.7.0.jar \
    -D mapred.reduce.tasks=8 \
    -input /data_mem  -output /distance_output_mem \
    -mapper /opt/hadoop-2.7.0/hadoop_code/distance/mapper_mem.py \
    -file /opt/hadoop-2.7.0/hadoop_code/distance/mapper_mem.py \
    -reducer /opt/hadoop-2.7.0/hadoop_code/distance/reducer_mem.py \
    -file /opt/hadoop-2.7.0/hadoop_code/distance/reducer_mem.py \
    >>hadoop.out 2>&1
    """
    os.system(cmd)
    
    
@count_time
def distance_hadoop_plus():
    """
    use memcached 
    """
    cmd = """
    hadoop jar /opt/hadoop-2.7.0/share/hadoop/tools/lib/hadoop-streaming-2.7.0.jar \
    -D mapred.reduce.tasks=8 \
    -input /data_plus  -output /distance_output_plus \
    -mapper /opt/hadoop-2.7.0/hadoop_code/distance/mapper_plus1.py \
    -file /opt/hadoop-2.7.0/hadoop_code/distance/mapper_plus1.py \
    -reducer /opt/hadoop-2.7.0/hadoop_code/distance/reducer_plus1.py \
    -file /opt/hadoop-2.7.0/hadoop_code/distance/reducer_plus1.py \
    >>hadoop.out 2>&1
    """
    os.system(cmd)
    cmd = """
    hadoop jar /opt/hadoop-2.7.0/share/hadoop/tools/lib/hadoop-streaming-2.7.0.jar \
    -D mapred.reduce.tasks=8 \
    -input /distance_output_plus  -output /distance_output_plus2 \
    -mapper /opt/hadoop-2.7.0/hadoop_code/distance/mapper_plus2.py \
    -file /opt/hadoop-2.7.0/hadoop_code/distance/mapper_plus2.py \
    -reducer /opt/hadoop-2.7.0/hadoop_code/distance/reducer_plus2.py \
    -file /opt/hadoop-2.7.0/hadoop_code/distance/reducer_plus2.py \
    >>hadoop.out 2>&1
    """
    os.system(cmd)

def euclDistance(vector1, vector2): 
    #time.sleep(1)
    return np.sqrt(np.sum(np.power(vector2 - vector1, 2)))




def main():
    if  "-h" in sys.argv or "--help" in sys.argv:
        print """eg:    ./distance.py 10 100 -n -d -hd
        10 is vector dimensionality
        100 is vector number
        -n create new data
        -d  one node distance
        -hd hadoop distance
        """
        return
    global vector_d
    global vector_n
    if len(sys.argv) >= 3:
        if "-" not in sys.argv[1]:
           vector_d = int(sys.argv[1])
        if "-" not in sys.argv[2]:
           vector_n = int(sys.argv[2])
    if "-n" in sys.argv:
        new_data()
    if "-d" in sys.argv:
        distance()
    if "-hd" in sys.argv:
        if "-n" in sys.argv:
            os.system("hdfs dfs -rm /data >>hadoop.out 2>&1")
            os.system("hdfs dfs -put ./data.txt /data >>hadoop.out 2>&1")
        os.system("hdfs dfs -rm -r /distance_output >hadoop.out 2>&1")
        os.system("rm -rf /root/hadoop_out.txt")
        os.system("ssh 191.168.45.104 rm -rf /root/hadoop_out.txt")
        distance_hadoop()
    if "-hd_mem" in sys.argv:
        if "-n" in sys.argv:
            os.system("hdfs dfs -rm /data_mem >>hadoop_mem.out 2>&1")
            os.system("hdfs dfs -put ./data.txt /data_mem >>hadoop.out 2>&1")
        os.system("hdfs dfs -rm -r /distance_output_mem >hadoop_mem.out 2>&1")
        os.system("rm -rf /root/hadoop_out_mem.txt")
        os.system("ssh 191.168.45.104 rm -rf /root/hadoop_out_mem.txt")
        distance_hadoop_mem()
    if "-hd_plus" in sys.argv:
        if "-n" in sys.argv:
            os.system("hdfs dfs -rm /data_plus >>hadoop_plus.out 2>&1")
            os.system("hdfs dfs -put ./data.txt /data_plus >>hadoop.out 2>&1")
        os.system("hdfs dfs -rm -r /distance_output_plus >hadoop_mem.out 2>&1")
        os.system("hdfs dfs -rm -r /distance_output_plus2 >hadoop_mem.out 2>&1")
        os.system("rm -rf /root/hadoop_out_plus.txt")
        os.system("ssh 191.168.45.104 rm -rf /root/hadoop_out_plus.txt")
        distance_hadoop_plus()

        
        



if __name__ == "__main__":
    sys.exit(main())

