#!/usr/bin/env python
# coding=utf-8

import subprocess
import os
import sys
import xlrd
import xlwt
import time

IOZONE="/opt/iozone/bin/iozone"
VOLUME_PATH="/mnt/ec_nfs/"
perf_path = "/mnt/ec_nfs/perf/"
volume = "dht-ec(8*(4+1))"
volume_type = "8-dht-ec-4-1"
client_num = 5
mount_type = "NFS"
FILE_SIZE="1G"
block = ["16K"]
progress = [100,200,250]
PATH = ["/mnt/ec_nfs/test_101","/mnt/ec_nfs2/test_102","/mnt/ec_nfs/test_103",
       "/mnt/ec_nfs/test_104","/mnt/ec_nfs/test_105"]
IP = ["60.60.1.11", "60.60.1.11", "60.60.1.12", "60.60.1.14", "60.60.1.15"]
stor_ip = ["60.60.1.101", "60.60.1.102", "60.60.1.103", "60.60.1.104", "60.60.1.105",]
def main():
    for b in block:
        for p in progress:
            start_time = time.time()
            dir1="%s%s_%s_%s_%dP" %(perf_path, volume_type, b, FILE_SIZE, p)
            cmd1 = "mkdir -p " + dir1
            os.system(cmd1)
            fileall = []
            xls_all = []
            for path in PATH:
                path_s = os.path.split(path)[1] # /mnt/ec_nfs/test_101 -> test_101
                filename = ""
                xls_name = dir1 + "/%s-%s-%s.xls" %(b, FILE_SIZE, path_s)
                for i in range(p):
                    filename = filename + path +"/testiozone-%s-%s-%s-%d "%(b,                          FILE_SIZE, path_s, i)
                fileall.append(filename)
                xls_all.append(xls_name)
            cmd = []
            for i in range(len(IP)):
                cmd1="ssh %s %s -i 0 -i 1 -r %s -s %s -t %d -F %s -Rb %s " % (IP[i], IOZONE, b, FILE_SIZE, p, fileall[i], xls_all[i])
                cmd.append(cmd1)
            process = []
            for i in range(len(cmd)):     
                p1 = subprocess.Popen(cmd[i], shell=True, stderr=subprocess.STDOUT,
                                  stdout=subprocess.PIPE)
                process.append(p1)
            time.sleep(2)
            cmd = []
            for i in range(len(stor_ip)):
                cmd1="ssh %s top -b -n 5 " % stor_ip[i]
                cmd.append(cmd1)
            proc_top = []
            for i in range(len(cmd)):     
                p1 = subprocess.Popen(cmd[i], shell=True, stderr=subprocess.STDOUT,
                                  stdout=subprocess.PIPE)
                proc_top.append(p1)
            for i in range(len(process)):
                f = open("%s/top_data_%s.txt" %(dir1, stor_ip[i]),"w")
                top_data = proc_top[i].stdout.readlines()
                f.writelines(top_data)
                f.close()
                
            cmd = []
            for i in range(len(stor_ip)):
                cmd1="ssh %s iostat -x -m 5 4 " % stor_ip[i]
                cmd.append(cmd1)
            proc_top = []
            for i in range(len(cmd)):     
                p1 = subprocess.Popen(cmd[i], shell=True, stderr=subprocess.STDOUT,
                                  stdout=subprocess.PIPE)
                proc_top.append(p1)
            for i in range(len(process)):
                f = open("%s/iostat_data_%s.txt" %(dir1, stor_ip[i]),"w")
                top_data = proc_top[i].stdout.readlines()
                f.writelines(top_data)
                f.close()
                
            for i in range(len(process)):
                process[i].wait()

            write = []
            re_write = []
            read = []
            re_read = []
            
            style = xlwt.XFStyle() #初始化样式
            font = xlwt.Font() #为样式创建字体
            font.name = 'Times New Roman'
            #font.bold = True
            style.font = font #为样式设置字体
            for xls in xls_all:
                data = xlrd.open_workbook(xls)
                table = data.sheets()[0]
                write.append(table.cell(4,2).value)
                re_write.append(table.cell(5,2).value)
                read.append(table.cell(6,2).value)
                re_read.append(table.cell(7,2).value)
            file1 = xlwt.Workbook()
            table_w = file1.add_sheet('Sheet1')
            
            data = xlrd.open_workbook("all.xls")
            table = data.sheets()[0]
            nrows = table.nrows
            ncols = table.ncols
            for i in range(nrows):
                for j in range(ncols):
                    table_w.write(i, j, table.cell(i,j).value, style)
            new_data= [volume, mount_type, client_num, FILE_SIZE, b, p, sum(write)
                       ,sum(re_write), sum(read), sum(re_read)]
            new_data.append("")
            new_data = new_data + write
            new_data.append("")
            new_data = new_data + re_write
            new_data.append("")
            new_data = new_data + read
            new_data.append("")
            new_data = new_data + re_read
            
            for i in range(len(new_data)):
                table_w.write(nrows, i, new_data[i], style)
            #table_w.write(nrows, 1, mount_type, style)
            #table_w.write(nrows, 2, client_num, style)
            #table_w.write(nrows, 3, FILE_SIZE, style)
            #table_w.write(nrows, 4, b, style)
            #table_w.write(nrows, 5, p, style)
            #table_w.write(nrows, 6, sum(write), style)
            #table_w.write(nrows, 7, sum(re_write), style)
            #table_w.write(nrows, 8, sum(read), style)
            #table_w.write(nrows, 9, sum(re_read), style)
            file1.save("all.xls")
            print "time: ", time.time() - start_time
            





if __name__ == "__main__":
    sys.exit(main())
