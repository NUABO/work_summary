#!/usr/bin/env python
# coding=utf-8

import re
import sys
import pickle
import os
#import codecs


def word(file_in, file_out):
    
    unknow_list  = []
    
    #fr =codecs.open(file_in,"r",'utf-8')
    fr = open(file_in, 'r')
    s = fr.read().strip()
    modify_dict = re.split("\s+",s)
    fr.close()
    
    filesize = os.path.getsize(file_out)
    if filesize != 0:
        f2 = open(file_out, "rb")
        words_dict = pickle.load(f2)
        f2.close()
    else:
        words_dict = {}
    
    print "update:"   
    for i in range(0,len(modify_dict),2):
        if modify_dict[i].lower() in words_dict:
            words_dict[modify_dict[i].lower()]["translation"][0] = modify_dict[i+1].decode("utf-8")
            print modify_dict[i]
    f1 = open("dict_new","wb")
    pickle.dump(words_dict, f1)
    f1.close()


def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    file_in = "modify_dict.txt"
    file_out = "dict_new"
    if len(sys.argv) >= 3:
        file_in = sys.argv[1]
        file_out = sys.argv[2]
    elif len(sys.argv) == 2:
        file_in = sys.argv[1]
        
    word(file_in, file_out)




if __name__ == "__main__":
    sys.exit(main())
