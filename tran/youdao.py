#!/usr/bin/env python
#coding:utf-8
#By eathings

import urllib2
import re
import json
import sys

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
        print "%13s" % "word: ",
        print words
        if json_result.has_key('translation'):
            translation = json_result["translation"]
            print "%13s" % "translation: ",
            for i in translation:
                print i,
            print ''
        if json_result.has_key('basic'):    
            basic = json_result["basic"]
            if basic.has_key('phonetic'):    
                phonetic = basic["phonetic"]
                print "%13s" % "phonetic: ",
                for i in phonetic:
                    print i,
                print ''
            if basic.has_key('uk-phonetic'):    
                uk_phonetic = basic["uk-phonetic"]
                print "%13s" % "uk-phonetic: ",
                for i in uk_phonetic:
                    print i,
                print ''
            if basic.has_key('explains'):    
                explains = basic["explains"]
                print "%13s" % "explains: ",
                for i in explains:
                    print i,
                print ''

            
def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    msg = "good"
    if len(sys.argv) >= 2:
        msg = sys.argv[1]
   
    youdao = Youdao()
    youdao.get_translation(msg)


if __name__ == "__main__":
    sys.exit(main())
