#!/usr/bin/env python
#coding:utf-8

import re
import sys
import os
stderr_old = sys.stderr
sys.stderr = open('/dev/zero', 'w') 
import paramiko
sys.stderr = stderr_old

def is_ucsd_start(address, volume, port = 22, user = "root", password = "123456" ):
   
    ssh = paramiko.SSHClient()
    try:
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(address, port, user, password)
        stdin, stdout, stderr = ssh.exec_command("/etc/init.d/ucsd status")
        s_ucsd = stdout.readlines()
        stdin, stdout, stderr = ssh.exec_command(
            "/usr/local/hstor/sms_install/ucsfs/sbin/ucs volume info %s" % volume)
        s_volume = stdout.readlines()
        ssh.close()
        if "running" in str(s_ucsd) and "Status: Started" in str(s_volume):
            return True
        else:
            return False
    except:
        return False

def main():
    if len(sys.argv)<3:
        print "python mount-ucsfs.py Volume mount_point"
    with open("ip","r") as f:
        ips = re.split("\s*",f.read().strip())
        for ip in ips:
            if is_ucsd_start(ip, sys.argv[1]):
                os.system("mount -t ucsfs %s:/%s %s" % (ip, sys.argv[1], sys.argv[2]))
                return
            
if __name__ == "__main__":
    sys.exit(main())
