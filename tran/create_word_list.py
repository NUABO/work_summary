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
            print "error: error code ",json_result["errorCode"],"word:",words
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
    
    filesize = os.path.getsize("dict")
    if filesize != 0:
        f2 = open("dict", "rb")
        words_dict = pickle.load(f2)
        f2.close()
    else:
        words_dict = {}
    
    youdao = Youdao()
    i = 0
    f = codecs.open(file_out, "w", 'utf-8') 
    f.write("<wordbook>\n")
    word_count = 0
    for word in unknow_list:
        try:
            s= ""
            if word.lower() not in words_dict:
                dict_word = youdao.get_translation(word.lower())
                if dict_word != -1:
                    i = i + 1
                    if i>500:
                        sleep(7)
                    words_dict[word.lower()] = dict_word
            else:
                dict_word = words_dict[word.lower()]
            phonetic =  dict_word.get("phonetic") or ""
            explains = " ".join( dict_word.get("explains") or [])
            if not explains:
                continue

            s = """    <item>
        <word>%s</word>
        <trans><![CDATA[%s]]></trans>
        <phonetic><![CDATA[[%s]]]></phonetic>
        <tags></tags>
        <progress>1</progress>
    </item>
""" %(word.lower(),explains, phonetic)
            f.write(s)
            word_count = word_count +1
        except:
            print "translate [%s] error" % word
            
    print "words : " , word_count
    f.write("</wordbook>")
    f.close()
            
    f1 = open("dict","wb")
    pickle.dump(words_dict, f1)
    f1.close()

def word_plus(file_in, file_out):
    
    unknow_list  = []
    unknow_plus  = []
    
    fr = open(file_in, 'r')
    s = fr.read().strip()
    unknow_list = re.split("\s+",s)
    fr.close()
    
    filesize = os.path.getsize("dict")
    if filesize != 0:
        f2 = open("dict", "rb")
        words_dict = pickle.load(f2)
        f2.close()
    else:
        words_dict = {}
    
    youdao = Youdao()
    i = 0

    word_count = 0
    for word in unknow_list:
        try:
            s= ""
            if word.lower() not in words_dict:
                dict_word = youdao.get_translation(word.lower())
                if dict_word != -1:
                    i = i + 1
                    if i>500:
                        sleep(7)
                    words_dict[word.lower()] = dict_word
            else:
                dict_word = words_dict[word.lower()]
            explains = " ".join( dict_word.get("explains") or [])
            if not explains:
                continue

        
            word = word.lower()
            if re.match("(.*s$)|(.*ing$)|(.*ed$)", word):
                m = re.match(".*(%s[A-Za-z]*).*" % word[:3], explains)
                if m:
                    print "%s -> %s" %(word ,m.groups()[0])
                    word = m.groups()[0]
                
            if  word not in unknow_plus:
                unknow_plus.append(word)
        except:
            print "translate [%s] error" % word
            
    i = 0
    fw = open(file_out, 'w')
    for key in sorted(unknow_plus):
        fw.write(key+"\n")
        i = i + 1
    fw.close()
    print "words : " ,i
            


def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    file_in = "unknow_word.txt"
    file_out = "word.xml"
    file_in_plus = "unknow_word_plus.txt"
    file_out_plus = "word_plus.xml"
    if len(sys.argv) >= 3:
        file_in = sys.argv[1]
        file_out = sys.argv[2]
    elif len(sys.argv) == 2:
        file_in = sys.argv[1]
        
    word(file_in, file_out)
    word_plus(file_in, file_in_plus)
    word(file_in_plus, file_out_plus)




if __name__ == "__main__":
    sys.exit(main())
