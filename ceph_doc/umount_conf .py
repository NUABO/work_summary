#!/usr/bin/env python
# coding=utf-8

#print_xattr.py

import os
import sys
import re
from configobj import ConfigObj, ConfigObjError
import subprocess


def main():
    conf_file = "/etc/ceph/ceph.conf"
    if len(sys.argv) >= 2:
        conf_file = sys.argv[1]
    try:
        conf = ConfigObj(conf_file)
    except ConfigObjError as err:
        print "Get config: error: %s" % err
        return -1
    process = []
    for key in conf:
        if key.startswith("osd."):
            osd_num = key.split(".")[1]
            host = conf[key]["public addr"]
            dev = conf[key]["devs"]
            mount_point = "/mnt/osd" + osd_num
            cmd = "ssh %s umount -l %s" % (host, mount_point)
            if "-p" not in sys.argv:
                os.system(cmd)
            else:
                p1 = subprocess.Popen(cmd, shell=True)
                process.append(p1)
            dev = dev[:-1]+str(int(dev[-1])+1)
            if conf[key].has_key("jour_devs"):
                dev = conf[key]["jour_devs"]
            mount_point = "/mnt/journal" + osd_num
            cmd = "ssh %s umount -l %s" % (host,  mount_point)
            if "-p" not in sys.argv:
                os.system(cmd)
            else:
                p1 = subprocess.Popen(cmd, shell=True)
                process.append(p1)
    
    for i in range(len(process)):
        process[i].wait()            



if __name__ == "__main__":
    sys.exit(main())

