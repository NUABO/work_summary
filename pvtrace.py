#!/usr/bin/env python
# coding=utf-8

#pvtrace.py

# getfattr -d -m ".*" -R .

import os
import sys
import re 


def main():
    if "-h" in sys.argv or "--help" in sys.argv:
        print "pvtrace.py  [*.txt]  [*.png]"
        return 
    in_file = "trace.txt"
    out_file = "out.png"
    for file_name in sys.argv:
        if ".txt" in file_name:
            in_file = file_name
        if ".png" in file_name:
            out_file = file_name
    f_w = open("graph.dot","w")
    f_w.write("digraph main { \n")
    f_r = open(in_file,'r')
    lines = f_r.readlines()
    f_r.close()
    for index, oneline in enumerate(lines):
        lines[index] = re.split('\s+',oneline.strip())
        lines[index][0] = int(lines[index][0])
    for index, oneline in enumerate(lines):
        if len(oneline)!=2:
            continue
        if index == 0:
            f_w.write("%s [shape=rectangle]\n" % oneline[1])
        else:
            #有子函数
            if oneline[0] < lines[index][0]:
                f_w.write("%s [shape=rectangle]\n" % oneline[1])
            else:
                f_w.write("%s [shape=ellipse]\n" % oneline[1])
            #找父函数
            index_p = index-1
            while index_p :
                if lines[index_p][0] < oneline[0]:
                    break;
                else:
                    index_p = index_p - 1
            f_w.write('%s -> %s [ fontsize="10"]\n' % (lines[index_p][1], oneline[1]))
    f_w.write('}\n')
    f_w.close()
    os.system("dot graph.dot -Tpng -o %s" % out_file)


if __name__ == "__main__":
    sys.exit(main())


