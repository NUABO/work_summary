#!/usr/bin/env python
# coding=utf-8

import re
import sys

def word(file_in, file_out):

    fr = open(file_in, 'r')
    s = fr.read()
    #s = re.sub("(<noscript>.*?</noscript>)","",s) #.是没有匹配换行符的
    s = re.sub("(<noscript>[\s\S]*?</noscript>)","",s)
    s = re.sub("(<script[\s\S]*?</script>)","",s)
    s = re.sub("(<[\s\S]*?>)","",s)
    
    fw = open(file_out, 'w')
    fw.write(s)
    print "ok"


def main():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    file_in = "a.html"
    file_out = "file.txt"
    if len(sys.argv) >= 3:
        file_in = sys.argv[1]
        file_out = sys.argv[2]
    elif len(sys.argv) == 2:
        file_in = sys.argv[1]
        
    word(file_in, file_out)




if __name__ == "__main__":
    sys.exit(main())
