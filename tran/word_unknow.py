#!/usr/bin/env python
# coding=utf-8

import re
import sys

def word(file_in, file_out):
    
    know_list  =  []
    words_list  = []
    lines_list  = []
    
    fr = open("know_word.txt", 'r')
    s = fr.read().strip()
    know_list = re.split("\s+",s)
    fr.close()
    with open(file_in, 'r') as f:
        for line in f:
            lines_list = line.split()
            for i in lines_list:
                # 只统计单词
                if not re.findall(r'[^a-zA-Z]+', i) :
                    if  i not in words_list:
                        words_list.append(i)
    fw = open(file_out, 'w')
    i = 0
    for key in sorted(words_list):
        if key not in know_list and key.lower() not in know_list:
            fw.write(key+"\n")
            i = i + 1
    fw.close()
    print "words : " ,i


def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    file_in = "file.txt"
    file_out = "unknow_word.txt"
    if len(sys.argv) >= 3:
        file_in = sys.argv[1]
        file_out = sys.argv[2]
    elif len(sys.argv) == 2:
        file_in = sys.argv[1]
        
    word(file_in, file_out)




if __name__ == "__main__":
    sys.exit(main())
