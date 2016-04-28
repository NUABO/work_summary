#!/usr/bin/env python
# coding=utf-8

import re
import sys
import os

words_list  = []


def word(know_list, file_in):
	if os.path.isdir(file_in):
		file_list = os.listdir(file_in)
		file_list.sort()
		for filename in file_list:
			if "-a" not in sys.argv:
				if filename[0] == '.':
					continue
				filename = os.path.join(file_in, filename)
				word(know_list, filename)
	elif os.path.isfile(file_in):
		#words_list  = []
		lines_list  = []
		
		with open(file_in, 'r') as f:
			for line in f:
				#把标点换成空格
				line=re.sub("[;,.?]\s"," ", line)
				lines_list = line.split()
				for i in lines_list:
					# 只统计单词,如果不存在非字母字符
					if not re.findall(r'[^a-zA-Z]+', i) :
						if  i not in words_list:
							words_list.append(i)
	else:
		print "%s is not exist." % file_in


def main():
	#from dbgp.client import brk
	#brk(host="191.168.45.215", port=50803)
	file_in = "translate"
	file_out = "unknow_word.txt"
	
	if len(sys.argv) >= 3:
		file_in = sys.argv[1]
		file_out = sys.argv[2]
	elif len(sys.argv) == 2:
		file_in = sys.argv[1] 
	know_list = []
	fr = open("know_word.txt", 'r')
	s = fr.read().strip()
	know_list = re.split("\s+",s)
	fr.close()
	word(know_list, file_in)
	fw = open(file_out, 'w')
	i = 0
	for key in sorted(words_list):
		if key not in know_list and key.lower() not in know_list:
			fw.write(key+"\n")
			i = i + 1
	fw.close()
	print "words : " ,i
	print "word_unknow success"



if __name__ == "__main__":
    sys.exit(main())
