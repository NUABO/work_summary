# -*- coding: utf-8 -*-

import pythoncom
import pyHook
import win32api
import win32con
import time
import sys
import os

pid_file = "clicktocopy_pid" 

    
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

def main():
    if os.path.exists(pid_file):
        print "the pid file is exist"
        return -1
    with open(pid_file, "w") as f:
        print os.getpid()
        f.write(str(os.getpid()))
    
    # 创建钩子管理对象
    hm = pyHook.HookManager()
    # 监听所有鼠标事件
    hm.MouseAll = OnMouseEvent # 等效于hm.SubscribeMouseAll(OnMouseEvent)
    # 开始监听鼠标事件
    hm.HookMouse()
    # 一直监听，直到手动退出程序
    pythoncom.PumpMessages()

if __name__ == "__main__":
    sys.exit(main())
