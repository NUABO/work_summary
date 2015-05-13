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



def translate(file_in, file_out):
    
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
        os.chdir("./translate")
    else:
        print "no dir translate"
        return
    file_list = os.listdir("./")
    for filename in file_list:
        if "tran_" in filename:
            continue
        f = open(filename,"r")
        f_w =codecs.open("tran_" + filename,"w",'utf-8')
        s= f.read()
        for word in unknow_list:
            tran = word+"(%s) "%words_dict[word.lower()]["translation"][0]
            s = re.sub(word+" ",tran,s)
        f_w.write(s)  
        f.close()
        f_w.close()
        



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
        
    translate(file_in, file_out)




if __name__ == "__main__":
    sys.exit(main())
