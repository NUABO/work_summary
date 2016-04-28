#!/usr/bin/env python
# coding=utf-8



import os
import sys
import time
import subprocess

process = []

def test_read(filename):
    global process
    print filename
    if "-p" in sys.argv:
        cmd = "cat %s >> /dev/null " % filename
        p1 = subprocess.Popen(cmd, shell=True, stderr=subprocess.STDOUT,
                                  stdout=subprocess.PIPE)
        process.append(p1)
    else:
        os.system("cat %s >> /dev/null " % filename)


def test_read_all(directory):
    if os.path.isdir(directory):
        file_list = os.listdir(directory)
        file_list.sort()
        for filename in file_list:
            if filename[0] == '.':
                continue
            filename = os.path.join(directory, filename)
            if os.path.isdir(filename):
                test_read_all(filename)
            else:
                test_read(filename)
    elif os.path.isfile(directory):
        test_read(directory)
    else:
        print "%s is not exist." % directory




def main():
    global process
    dir_in = "/mnt/"
    if  "-h" in sys.argv or "--help" in sys.argv:
        print """eg:     ./test_read.py /mnt  -p
        /mnt/ is file directory
        -p is Parallel Read
        """
        return 
    if len(sys.argv) >= 2:
        dir_in = sys.argv[1]
        
    start_time = time.time()
    print time.ctime()
    test_read_all(dir_in)
    for i in range(len(process)):
        process[i].wait()
    print "time: ", time.time() - start_time
    print time.ctime()



if __name__ == "__main__":
    sys.exit(main())

