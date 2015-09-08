#!/usr/bin/env python
# coding=utf-8

import re
import sys

def word(file_in, file_out):
    
    know_list  =  []
    unknow_list  = []
    unknow_list_new  = []
    
    fr = open("know_word.txt", 'r')
    s = fr.read().strip()
    know_list = re.split("\s+",s)
    fr.close()
    fr = open(file_in,'r')
    s = fr.read().strip()
    unknow_list = re.split("\s+",s)
    fr.close()
    fr = open(file_out, 'r')
    s = fr.read().strip()
    unknow_list_new = re.split("\s+",s)
    fr.close()
    
    for word in unknow_list:
        if word not in unknow_list_new:
            know_list.append(word.lower())
            
    fw = open("know_word.txt", 'w')
    i = 0
    for key in sorted(know_list):
            fw.write(key+"\n")
            i = i + 1
    fw.close()
    print "words : " ,i


def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    file_in = "unknow_word.txt"
    file_out = "unknow_word_new.txt"
    if len(sys.argv) >= 3:
        file_in = sys.argv[1]
        file_out = sys.argv[2]
    elif len(sys.argv) == 2:
        file_in = sys.argv[1]
        
    word(file_in, file_out)




if __name__ == "__main__":
    sys.exit(main())
