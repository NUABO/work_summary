#!/usr/bin/env python
# coding=utf-8

#print_xattr.py

import os
import sys
import re
import subprocess




def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    if len(sys.argv)<2 or '-h' in sys.argv:
        print """my_cmd.py cmd -o -p
        -p : print the cmd, not exec
example : my_cmd.py "mount /dev/sd[a-c]1 /mnt/osd[1-3]" -o
mean:
mount /dev/sda1 /mnt/osd1
mount /dev/sdb1 /mnt/osd2
mount /dev/sdc1 /mnt/osd3
example : my_cmd.py "umount /dev/sd[a-b][1-2]" 
mean:
umount /dev/sda1
umount /dev/sdb1
umount /dev/sda2
umount /dev/sdb2
"""
        return 

    s = sys.argv[1]
    range_list = re.findall("\[.*?\]",s)
    g=re.sub("\[.*?\]", "%s", s)
    
    cmd_args = []
    for range_str in range_list:
        ragge_str = range_str[1:-1] #?绘.[]
        start_end = ragge_str.split("-")
        if start_end[0].isdigit():
            ran = range(int(start_end[0]),int(start_end[1])+1)
            ran = map(str, ran)
        elif start_end[0].isalpha():
            ran = range(ord(start_end[0]),ord(start_end[1])+1)
            ran = map(chr, ran)
        else:
            print "cmd is error"
            return -1
        if not cmd_args:
            cmd_args = ran
        else:
            if "-o" in sys.argv:
                cmd_args_tmp = []
                if len(ran) != len(cmd_args):
                    print "cmd is error"
                    return -1
                for index in range(len(ran)):
                        cmd_args_tmp.append(cmd_args[index] + "," + ran[index])
                cmd_args = cmd_args_tmp
            else:
                cmd_args_tmp = []
                for ch in ran:
                    for arg in cmd_args:
                        cmd_args_tmp.append(arg + "," + ch)
                cmd_args = cmd_args_tmp

    process =[]
    for args in cmd_args:
        args_tuple = tuple(args.split(","))
        exec('cmd = g % args_tuple')
        if "-p" in sys.argv:
            print cmd
        else:
            if "-s" not in sys.argv:
                os.system(cmd)
            else:
                p1 = subprocess.Popen(cmd, shell=True)
                process.append(p1)
            
    for i in range(len(process)):
        process[i].wait()




if __name__ == "__main__":
    sys.exit(main())