#!/usr/bin/env python
# coding=utf-8

from socket import *

import time
import argparse
import sys
import os
import subprocess
import re



USAGE = """%s [options]
eg: python rbd_multi_client_cluster.py -p rep-pool -i volume-1 -b 4M -f 1 -c 80

"""
          
cliet_ip = ["60.60.1.11", "60.60.1.12"]
stor_ip = ["60.60.1.103", "60.60.1.104", "60.60.1.105"]   
perf_path = "/root/data/"      

def main():
    parser = argparse.ArgumentParser(usage=USAGE)
    parser.add_argument('-p', '--pool', 
            default="127.0.0.1", help='The pool name of ceph rbd')
    parser.add_argument('-i', '--image',
                        default="",help='The image name of ceph rbd')
    parser.add_argument('-b', '--block', metavar="*B,*K,*M",
            default="1k", help='block size.')
    parser.add_argument('-c', '--client', type=int,
            default="2", help='client number.')
    parser.add_argument('-f', '--filesize', type=int,
            default="10", help='filesize size.')
    parser.add_argument('-d', '--dir',
                        default="rep-1",help='The prefix of dir name') #目录名的前缀，用于区分不同环境的测试
    
    
    args = sys.argv[1:]
    opts = parser.parse_args(args)
    
    
    dir1="%s%s_%dserv_%dstor_%s_%dG_%dc" %(perf_path, opts.dir, len(cliet_ip), len(stor_ip), opts.block, opts.filesize, opts.client)
    os.system("mkdir -p %s" % dir1)
    cmd = []
    host_client_num = opts.client/len(cliet_ip)
    for i in range(len(cliet_ip)):
        cmd1="ssh %s python /root/rbd_multi_client_local.py -p %s -i %s -b %s -f %d -c %d -o %d" % (cliet_ip[i], opts.pool, opts.image, opts.block, opts.filesize/opts.client, host_client_num, i*host_client_num*opts.filesize/opts.client)
        cmd.append(cmd1)
    process = []
    for i in range(len(cmd)):     
        p1 = subprocess.Popen(cmd[i], shell=True, stderr=subprocess.STDOUT,
                          stdout=subprocess.PIPE)
        process.append(p1)
        
    # start collect performance data  
    time.sleep(3)
    cmd = []
    for i in range(len(stor_ip)):
        cmd1="ssh %s top -b -n 5 " % stor_ip[i]
        cmd.append(cmd1)
    proc_top = []
    for i in range(len(cmd)):     
        p1 = subprocess.Popen(cmd[i], shell=True, stderr=subprocess.STDOUT,
                          stdout=subprocess.PIPE)
        proc_top.append(p1)
    for i in range(len(proc_top)):
        f = open("%s/storage_top_data_%s.txt" %(dir1, stor_ip[i]),"w")
        top_data = proc_top[i].stdout.readlines()
        f.writelines(top_data)
        f.close()
        
    cmd = []
    for i in range(len(cliet_ip)):
        cmd1="ssh %s top -b -n 5 " % cliet_ip[i]
        cmd.append(cmd1)
    proc_top = []
    for i in range(len(cmd)):     
        p1 = subprocess.Popen(cmd[i], shell=True, stderr=subprocess.STDOUT,
                          stdout=subprocess.PIPE)
        proc_top.append(p1)
    for i in range(len(proc_top)):
        f = open("%s/client_top_data_%s.txt" %(dir1, cliet_ip[i]),"w")
        top_data = proc_top[i].stdout.readlines()
        f.writelines(top_data)
        f.close()
        
    cmd = []
    for i in range(len(stor_ip)):
        cmd1="ssh %s iostat -x -m 2 5 " % stor_ip[i]
        cmd.append(cmd1)
    proc_top = []
    for i in range(len(cmd)):     
        p1 = subprocess.Popen(cmd[i], shell=True, stderr=subprocess.STDOUT,
                          stdout=subprocess.PIPE)
        proc_top.append(p1)
    for i in range(len(proc_top)):
        f = open("%s/storage_iostat_data_%s.txt" %(dir1, stor_ip[i]),"w")
        top_data = proc_top[i].stdout.readlines()
        f.writelines(top_data)
        f.close()
        
    # end collect performance data     
        
        
        
        
        
    f = open("%s/speed_data.txt" % dir1,"w")
    for i in range(len(process)):
        process[i].wait()
    all_speed = 0.0 
    max_time = []
    sum_time = 0.0
    for i in range(len(process)):
        data = process[i].stdout.readlines()
        try:
            m = re.match("speed_sum = (.*)KB/s",data[-3])
            all_speed  = all_speed + float(m.groups()[0])
            m = re.match("max_time = ([0-9\.]*)",data[-5])
            max_time.append(float(m.groups()[0]))
            m = re.match("sum_time = ([0-9\.]*)",data[-4])
            sum_time = sum_time + float(m.groups()[0])
        except:
            pass
        print cliet_ip[i],": "
        f.write(cliet_ip[i]+": \n")
        print "\t","\t".join(data)
        f.write("\t" + "\t".join(data) + "\n")
        
    str1 =  "speed_sum = %fKB/s\n" % all_speed
    str1 = str1 + "speed_max_time = %fKB/s\n" % (opts.filesize*1024*1024  / max(max_time))
    str1 = str1 + "speed_avg_time = %fKB/s\n" % (opts.filesize*1024*1024  / (sum_time / opts.client) )
    print str1,
    
    f.write(str1)
    f.close()
    f = open("%s/speed_data.txt" % perf_path,"a+")
    f.write(" ".join(sys.argv)+"\n")
    f.write(str1+"\n")
    f.close()
    
 

    
if __name__ == "__main__":
    sys.exit(main())  










