#!/usr/bin/env python
# coding=utf-8

import re
import sys
import pickle
import os
import urllib2
import json
import codecs
from time import sleep



def translate_all(file_in, file_out):
    
    unknow_list  = []
    
    fr = open(file_in, 'r')
    s = fr.read().strip()
    unknow_list = re.split("\s+",s)
    fr.close()
    
    filesize = os.path.getsize(file_out)
    if filesize != 0:
        f2 = open(file_out, "rb")
        words_dict = pickle.load(f2)
        f2.close()
    else:
        print "dict is empty"
        return 
    if os.path.isdir("translate"):
        pass
    else:
        print "no dir translate"
        return
    #os.mkdir("translate_tran")
    translate(unknow_list, words_dict, "translate", "translate_tran")
    print "translate success"

def translate(unknow_list, words_dict, before, after):
    if os.path.isdir(before):
        file_list = os.listdir(before)
        file_list.sort()
        for filename in file_list:
            if "-a" not in sys.argv:
                if filename[0] == '.':
                    continue
            filename_b = os.path.join(before, filename)
            filename_a = os.path.join(after, filename)
            translate(unknow_list, words_dict, filename_b, filename_a)
    elif os.path.isfile(before):
        f = open(before,"r")
        f_w =codecs.open(after,"w",'utf-8')
        for line in f:
            line = unicode(line,'utf-8')
            lines_list = line.split()
            for i in lines_list:
                # 只统计单词
                if not re.findall(r'[^a-zA-Z]+', i) :
                    if i in unknow_list and i.lower() in words_dict:
                        tran = i+"(%s)"%words_dict[i.lower()]["translation"][0]
                        #line = unicode(line)
                        line = line.replace(i,tran)
            f_w.write(line)  
        f.close()
        f_w.close()
    else:
        print "%s is not exist." % before
    



def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    file_in = "unknow_word.txt"
    file_out = "dict"
    if len(sys.argv) >= 3:
        file_in = sys.argv[1]
        file_out = sys.argv[2]
    elif len(sys.argv) == 2:
        file_in = sys.argv[1]
        
    translate_all(file_in, file_out)




if __name__ == "__main__":
    sys.exit(main())
