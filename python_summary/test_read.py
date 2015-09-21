#!/usr/bin/env python
# coding=utf-8

#字典按键值排序
import operator
classCount = {'a':1,'b':4,'c':2}
print sorted(classCount.iteritems(), key=operator.itemgetter(1), reverse=True)
# [('b', 4), ('c', 2), ('a', 1)]

#python单例模式
#http://ghostfromheaven.iteye.com/blog/1562618
def singleton(cls, *args, **kw):  
    instances = {}  
    def _singleton():  
        if cls not in instances:  
            instances[cls] = cls(*args, **kw)  
        return instances[cls]  
    return _singleton  
@singleton  
class MyClass4(object):  
    a = 1  
    def __init__(self, x=0):  
        self.x = x  

#保存中文文件内容
import codecs
#with codecs.open( filename, "w", 'utf-8') as f:


if __name__ == "__main__":
    sys.exit(main())

