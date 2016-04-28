#!/usr/bin/env python
#coding=utf-8

import time
import sys
import os


          
block = ["4M", "8M", "16M", "32M", "64M", "128M", "256M", "512M"]
client_num = [2, 4, 8, 16, 32, 64, 128, 256]         
f = 256
def main():
    cmd= "python rbd_multi_client_cluster.py -d rep_1_5ssd_40disk -p rep-pool -i volume-1 -b 16M -f %d -c 64" % f
    #os.system(cmd)
    for b in block:
        for c in client_num:
            if int(b[:-1])*c < 160 or int(b[:-1])*c >= 1024*7:
                continue
            cmd= "python rbd_multi_client_cluster.py -d rep_1_5ssd_40disk -p rep-pool -i volume-1 -b %s -f %d -c %d " %(b, f, c)
            print time.ctime()
            print cmd
            os.system(cmd)   
   
if __name__ == "__main__":
    sys.exit(main())  

