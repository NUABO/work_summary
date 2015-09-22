#!/usr/bin/env python
#coding:utf-8
#By eathings

import urllib2
import re
import json
import sys
import xerox
import time
import signal
import os
import traceback
import operator
import codecs

import pythoncom
import pyHook
import win32api
import win32con
import threading
import subprocess


try:
    import cPickle as pickle
except:
    import pickle

pid_file = "clicktocopy_pid" 

class Youdao:
    def __init__(self):
        self.url = 'http://fanyi.youdao.com/openapi.do'
        self.key = '1333588662' #有道API key
        self.keyfrom = 'chenzhongtao' #有道keyfrom

    def get_translation(self,words):
        url = self.url + '?keyfrom=' + self.keyfrom + '&key='+self.key +\
            '&type=data&doctype=json&version=1.1&q=' + words
        result = urllib2.urlopen(url).read()
        try:
            json_result = json.loads(result)
        except BaseException:
            print traceback.format_exc()
            print "error translation ", words
            return -1
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

flag = True

def main2():
    #from dbgp.client import brk
    #brk(host="191.168.45.215", port=50803)
    #msg = "good"
    #if len(sys.argv) >= 2:
    #   msg = sys.argv[1]
    global flag
    def handler(signum, frame):
        print 'Signal handler called with signal', signum
        while True:
            in_put = raw_input("please input 'c' continue or 'e' exit:")
            if in_put == 'e':
                #exit()
                global flag
                flag = False
                break
            elif in_put == 'c':
                break
    signal.signal(signal.SIGINT, handler)
    youdao = Youdao()
    #youdao.get_translation(msg)
    print "start youdao_copy"
    word = xerox.paste()
    while(flag):
        word_new = xerox.paste()
        if word_new != word:
            print word_new
            youdao.get_translation(word_new)
            word = word_new
        else:
            time.sleep(0.1)
            
    print "exit youdao_copy"

def handler(signum, frame):
    #print os.getpid()
    print 'Signal handler called with signal', signum
    ins_copy = Youdao_copy()
    while True:
        in_put = raw_input("please input :\n 'c': continue \n 'e': exit\n"
            +" 'r': change record_file\n 'b': change if use bracket\n"+
            " 's': write statistical information\n 't': translate record file\n:")
        if in_put == 'e':
            #exit()
            ins_copy.run_flag = False
            break
        elif in_put == 'c':
            break
        elif in_put == 'r':
            file_name = raw_input("please input a file name:")
            ins_copy.record_file = file_name
            ins_copy.reopen_record()
            break
        elif in_put == 'b':
            ins_copy.without_bracket = not ins_copy.without_bracket
            break
        elif in_put == 's':
            file_name = raw_input("please input a file name or input 'all':")
            ins_copy.statistics(file_name)
            break
        elif in_put == 't':
            file_name = raw_input("please input a file name or input 'all':")
            ins_copy.translate(file_name)
            break
        
def listalldir(file_list, dir_par):
    if not isinstance(file_list, list):
        print "error: the file_list must be list"
        return
    if not os.path.exists(dir_par):
        print "error: the path %s is not exists" % dir_par
        return 
    if os.path.isdir(dir_par):
        files = os.listdir(dir_par)
        for f in files:
            filename = os.path.join(dir_par, f)
            if os.path.isdir(filename):
                listalldir(file_list, filename)
            else:
                file_list.append(filename)
    else:
        file_list.append(dir_par)
    
#单例模式    
def singleton(cls, *args, **kw):
    # 居然是所有调用_singleton共用的
    instances = {}  
    def _singleton():  
        if cls not in instances:  
            instances[cls] = cls(*args, **kw)  
        return instances[cls]  
    return _singleton

@singleton  
class Youdao_copy(object):  
    def __init__(self):  
        self.run_flag = True
        self.without_bracket = False
        self.pid = None
        self.dict_file = "dict"
        self.record_dire = "record"
        self.record_file = "default.txt"
        self.words_dict = None
        self.f_record = None
        self.load_dict()
        self.open_record()

        
        
    def load_dict(self):
        if os.path.exists(self.dict_file) and os.path.getsize(self.dict_file):
            f_dict = open(self.dict_file, "rb")
            self.words_dict = pickle.load(f_dict)
            f_dict.close()
        else:
            self.words_dict = {}
            
    def save_dict(self):
        f_dict = open(self.dict_file, "wb")
        pickle.dump(self.words_dict, f_dict)
        f_dict.close()
        
    def open_record(self):
        if not os.path.exists(self.record_dire):
            os.mkdir(self.record_dire)
        self.f_record = open(os.path.join(self.record_dire,self.record_file), "a")
    def reopen_record(self):
        self.f_record.close()
        self.f_record = open(os.path.join(self.record_dire,self.record_file), "a")
        
    def statistics(self, filename):
        self.f_record.flush()
        word_list = []
        stat = {}
        file_list = []
        if filename == "all":
            listalldir(file_list, self.record_dire)
        else:
            listalldir(file_list, os.path.join(self.record_dire,filename))
            
        for fn in file_list:
            fr = open(fn, "r")
            s = fr.read().strip()
            f_list = re.split("\s+",s)
            word_list.extend(f_list)
            fr.close()
        
        for w in word_list:
            if not w:
                continue
            if  w not in stat:
                stat[w] = 1
            else:
                stat[w] = stat[w] + 1
        stat_sort = sorted(stat.iteritems(), key=operator.itemgetter(1), reverse=True)
        with codecs.open("stat_" + filename, "w", 'utf-8') as f:
            youdao = Youdao()
            for item in stat_sort:
                if item[0] not in self.words_dict:
                        dict_word = youdao.get_translation(item[0])
                        if dict_word == -1:
                                continue
                        self.words_dict[item[0]] = dict_word
                else:
                    dict_word = self.words_dict[item[0]]
                if dict_word == -1:
                    continue
                s= "%15s" % item[0] + ' ' + str(item[1]) + '\t'
                s= s + (" ".join(self.words_dict[item[0]].get("translation")) or []) + '\t'
                s= s + (self.words_dict[item[0]].get("phonetic") or "") + '\t'
                s= s + (self.words_dict[item[0]].get("uk-phonetic") or "") + '\t'
                s= s + (" ".join(self.words_dict[item[0]].get("explains")) or []) + '\n'
                f.write(s)
    def translate(self, filename):
        def my_mkdir(new_dir):
            par_dir = os.path.split(new_dir)[0]
            if par_dir and not os.path.exists(par_dir):
                my_mkdir(par_dir)
            if not os.path.exists(new_dir):
                os.mkdir(new_dir)
                
        self.f_record.flush()
        word_list = []
        stat = {}
        file_list = []
        if filename == "all":
            listalldir(file_list, self.record_dire)
        else:
            listalldir(file_list, os.path.join(self.record_dire,filename))
        
        if not os.path.exists(self.record_dire+"tran"):
            os.mkdir(self.record_dire+"tran")
        for fn in file_list:
            fn_tran = fn.replace(self.record_dire, self.record_dire + "tran")
            fr = open(fn, "r")
            s = fr.read().strip()
            f_list = re.split("\s+",s)
            fr.close()
            par_dir = os.path.split(fn_tran)[0]
            my_mkdir(par_dir)
            with codecs.open(fn_tran, "w", 'utf-8') as f:
                youdao = Youdao()
                for item in f_list:
                    if item not in self.words_dict:
                            dict_word = youdao.get_translation(item)
                            if dict_word == -1:
                                continue
                            self.words_dict[item] = dict_word
                    else:
                        dict_word = self.words_dict[item]
                    if dict_word == -1:
                        continue
                    s= "%15s" % item + ' '
                    s= s + (" ".join(self.words_dict[item].get("translation")) or []) + '\t'
                    s= s + (self.words_dict[item].get("phonetic") or "") + '\t'
                    s= s + (self.words_dict[item].get("uk-phonetic") or "") + '\t'
                    s= s + (" ".join(self.words_dict[item].get("explains")) or []) + '\n'
                    f.write(s)
       
        
        
    def print_dict(self, word):
        if not self.words_dict.has_key(word):
            return
        dict_word = self.words_dict[word]
        if not isinstance(dict_word,dict):
            print "get the dict of %s error" % dict_word
            self.words_dict.pop(word)
            return 
        print "%13s" % "word: ",
        print word
        if dict_word.has_key('translation'):
            translation = dict_word["translation"]
            print "%13s" % "translation: ",
            for i in translation:
                print i,
            print ''

        if dict_word.has_key('phonetic'):    
            phonetic = dict_word["phonetic"]
            print "%13s" % "phonetic: ",
            print phonetic
            #for i in phonetic:
            #    print i,
            #print ''
        if dict_word.has_key('uk-phonetic'):    
            uk_phonetic = dict_word["uk-phonetic"]
            print "%13s" % "uk-phonetic: ",
            #for i in uk_phonetic:
            #    print i,
            #print ''
            print uk_phonetic
        if dict_word.has_key('explains'):    
            explains = dict_word["explains"]
            print "%13s" % "explains: ",
            for i in explains:
                print i,
            print '\n\n'
        
    def run(self):
        youdao = Youdao()
        #youdao.get_translation(msg)
        print "start youdao_copy"
        xerox.copy("你好")
        word = None
        word_new =None
        err_old = None
        try :
            word = xerox.paste()
        except BaseException,err:
            print err
        while(self.run_flag):
            try :
                try :
                    word_new = xerox.paste()
                    if re.findall(r'[^a-zA-Z\ ,.]+', word_new):
                        time.sleep(0.1)
                        continue
                    
                    #err_old = None
                except BaseException,err_old:
                    #if err_old == None:
                    print err_old
                    xerox.copy("你好")
                    word = "你好"
                if word_new != word:
                    #如果不存在非字母字符
                    if not re.findall(r'[^a-zA-Z\ ]+', word_new):
                        if word_new.lower() not in self.words_dict:
                            dict_word = youdao.get_translation(word_new.lower())
                            if not isinstance(dict_word,dict):
                                word = word_new
                                continue
                            self.words_dict[word_new.lower()] = dict_word
                        else:
                            dict_word = self.words_dict[word_new.lower()]
                            if not isinstance(dict_word,dict):
                                word = word_new
                                continue
                        self.print_dict(word_new.lower())
                        self.f_record.write(word_new.lower()+"\n")
                        
                        if self.without_bracket:
                            translation = "%s" % dict_word.get("translation")[0]
                            print translation
                        else:
                            translation = "(%s)" % dict_word.get("translation")[0]
                        #把中文翻译放到粘贴板
                            print translation
                        xerox.copy(translation.encode('gb2312'))
                        #import pdb
                        #pdb.set_trace()
                    word = word_new  
                else:
                    time.sleep(0.1)
            except BaseException:
                print traceback.format_exc()
            
        # 退出前的动作       
        self.save_dict()
        self.f_record.close()
        # windows 杀死进程的方法
        #cmd = "tskill %d" % self.pid
        #os.system(cmd)
        #杀不死不在同一控制台的后台进程， shell=True 会有 subprocess.CREATE_NEW_CONSOLE
        #self.subprocess.kill()
        os.kill(self.pid, 9)
        os.remove(pid_file)
        #os.kill(self.subprocess.pid, 15)
        print "exit youdao_copy"
  
#识别双击
last_click_time = 0
double_click = False
def OnMouseEvent(event):
    global last_click_time
    global double_click
    if event.Message == 513:
        if event.Time - last_click_time < 400:
            #双击，实现复制
            double_click = True   
        last_click_time = event.Time
    if event.Message == 514:
        if double_click:
            #双击，实现复制
            time.sleep(0.2)
            win32api.keybd_event(17,0,0,0) #ctrl键位码是17
            win32api.keybd_event(67,0,0,0) #c键位码是67
            win32api.keybd_event(67,0,win32con.KEYEVENTF_KEYUP,0) #释放按键
            win32api.keybd_event(17,0,win32con.KEYEVENTF_KEYUP,0)
            double_click = False   

    # 返回 True 可将事件传给其它处理程序，否则停止传播事件
    return True  

def hook_main():
    # 创建钩子管理对象
    hm = pyHook.HookManager()
    # 监听所有鼠标事件
    hm.MouseAll = OnMouseEvent # 等效于hm.SubscribeMouseAll(OnMouseEvent)
    # 开始监听鼠标事件
    hm.HookMouse()
    # 一直监听，直到手动退出程序
    pythoncom.PumpMessages()
    
def fun():
    while(True):
        time.sleep(5)
        
def main():
    signal.signal(signal.SIGINT, handler)
    cmd = "python.exe clicktocopy.py"
    p = subprocess.Popen(cmd, stdin = subprocess.PIPE, stdout = subprocess.PIPE,
                         stderr = subprocess.PIPE, shell = True, creationflags = subprocess.CREATE_NEW_PROCESS_GROUP)
    #后台进程的pid 不是 p.pid,是p.pid的子孙进程
    #print p.stdout.readline()
    # 等待另一个进程创建文件
    while not os.path.exists(pid_file):
        time.sleep(0.1)
    ins_copy = Youdao_copy()
    try:
        with open(pid_file,"r") as f:
            ins_copy.pid = int(f.readline().strip())
        ins_copy.run()
    except BaseException,err:
        ins_copy.save_dict()
        #os.system(cmd)
        os.kill(ins_copy.pid, 9)
        os.remove(pid_file)
        print err
        print traceback.format_exc()
        
        
if __name__ == "__main__":
    sys.exit(main())
