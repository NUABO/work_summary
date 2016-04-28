#!/usr/bin/env python
# coding=utf-8

import re

file_name = 'test.txt'

lines_count = 0
words_count = 0
chars_count = 0
words_dict  = {}
lines_list   = []

with open(file_name, 'r') as f:
    for line in f:
        lines_count = lines_count + 1
        chars_count  = chars_count + len(line)
        lines_list = line.split()
        for i in lines_list:
            # 只统计单词
            if not re.findall(r'[^a-zA-Z]+', i) :
                if  i not in words_dict:
                    words_dict[i] = 1
                else:
                    words_dict[i] = words_dict[i] + 1

print 'words_count is', len(words_dict)
print 'lines_count is', lines_count
print 'chars_count is', chars_count

#for k,v in words_dict.items():
#    print k,v
for key in sorted(words_dict):
    print key,words_dict[key]


