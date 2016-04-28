#!/usr/bin/env python
# coding=utf-8



import os
import sys
import time
import subprocess



def test_write(directory, file_num, count):
    process = []
    for i in range(file_num):
        filename = "%05d" % i
        filename = os.path.join(directory, filename)
        print filename
        if "-p" in sys.argv:
            cmd = "dd if=/dev/zero of=%s bs=1M count=%d " % (filename, count)
            p1 = subprocess.Popen(cmd, shell=True, stderr=subprocess.STDOUT,
                                      stdout=subprocess.PIPE)
            process.append(p1)
        else:
            os.system("dd if=/dev/zero of=%s bs=1M count=%d" % (filename, count))
    for i in range(len(process)):
        process[i].wait()


def main():
    dir_in = "/mnt/"
    if  "-h" in sys.argv or "--help" in sys.argv:
        print """eg:    ./test_write.py 40 100 /mnt/test/ -p
        40 is file number
        100 is file size :100M
        /mnt/test/ is file directory
        -p is Parallel Write
        """
        return 
    file_num = int(sys.argv[1])
    count = int(sys.argv[2])
    if len(sys.argv) >= 4:
        dir_in = sys.argv[3]
        
    start_time = time.time()
    print time.ctime()
    test_write(dir_in, file_num, count)
    print "time: ", time.time() - start_time
    print time.ctime()



if __name__ == "__main__":
    sys.exit(main())

