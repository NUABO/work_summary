#!/usr/bin/env python
# coding=utf-8

import re
import sys
import pickle
import os
import urllib2
import json
from time import sleep


class Youdao:
    def __init__(self):
        self.url = 'http://fanyi.youdao.com/openapi.do'
        self.key = '1333588662' #有道API key
        self.keyfrom = 'chenzhongtao' #有道keyfrom

    def get_translation(self,words):
        url = self.url + '?keyfrom=' + self.keyfrom + '&key='+self.key +            '&type=data&doctype=json&version=1.1&q=' + words
        result = urllib2.urlopen(url).read()
        json_result = json.loads(result)
        if json_result.has_key('errorCode') and json_result["errorCode"] != 0:
            print "error: error code ",json_result["errorCode"]
            return -1
        dict_word = {}
        if json_result.has_key('translation'):
            dict_word ["translation"] = json_result["translation"]
        if json_result.has_key('basic'):    
            basic = json_result["basic"]
            if basic.has_key('phonetic'):    
                dict_word ["phonetic"] = basic["phonetic"]
            if basic.has_key('uk-phonetic'):    
                dict_word ["uk-phonetic"] = basic["uk-phonetic"]
            if basic.has_key('explains'):    
                dict_word ["explains"] = basic["explains"]
        return dict_word

def word(file_in, file_out):
    
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
        words_dict = {}
    
    youdao = Youdao()
    i = 0
    for word in unknow_list:
        if word.lower() not in words_dict:
            dict_word = youdao.get_translation(word.lower())
            if dict_word != -1:
                i = i + 1
                if i>500:
                    sleep(7)
                words_dict[word.lower()] = dict_word
            
    f1 = open("dict_new","wb")
    pickle.dump(words_dict, f1)
    f1.close()


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
        
    word(file_in, file_out)




if __name__ == "__main__":
    sys.exit(main())
