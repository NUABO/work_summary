#!/usr/bin/env python
# coding=utf-8

#print_xattr.py

import os
import sys
import re
from configobj import ConfigObj, ConfigObjError



def main():
    conf_file = "/etc/ceph/ceph.conf"
    if len(sys.argv) >= 2:
        conf_file = sys.argv[1]
    try:
        conf = ConfigObj(conf_file)
    except ConfigObjError as err:
        print "Get config: error: %s" % err
        return -1
    for key in conf:
        if key.startswith("osd."):
            osd_num = key.split(".")[1]
            host = conf[key]["public addr"]
            mount_point = "/mnt/osd" + osd_num
            cmd = "ssh %s /etc/init.d/ceph start %s" % (host, key)
            os.system(cmd)
            



if __name__ == "__main__":
    sys.exit(main())

