#! /bin/bash

device_ceph=/dev/rbd0
output=ceph-output.txt
size=10G
runtime=60

echo  "" | tee  $output

for bs in 4K 32k 128k 512k
do
        echo  "\n\n" | tee -a  $output
        echo "fio -bs=$bs -direct=1 -thread -rw=randwrite -size=$size -filename=$device_ceph -name=\"ceph EBS $bs randwrite test\" -iodepth=32 -runtime=$runtime" | tee -a $output
        fio -bs=$bs -direct=1 -thread -rw=randwrite -size=$size -filename=$device_ceph -name="ceph EBS 4KB randwrite test" -iodepth=32 -runtime=$runtime | tee -a $output
done

for bs in 4K 32k 128k 512k
do
        echo  "\n\n" | tee -a $output
        echo "fio -bs=$bs -direct=1 -thread -rw=randread -size=$size -filename=$device_ceph -name=\"ceph EBS $bs randread test\" -iodepth=32 -runtime=$runtime" | tee -a $output
        fio -bs=$bs -direct=1 -thread -rw=randread -size=$size -filename=$device_ceph -name="ceph EBS 4KB randread test" -iodepth=32 -runtime=$runtime | tee -a $output
done

echo "\nwrite bw:"
cat $output | grep bw= |grep  write  | awk '{print substr($3,4,length($3)-4)}'
echo "\nwrite iops:"
cat $output | grep iops= |grep  write  | awk '{print substr($4,6,length($4)-6)}'

echo "\nread bw:"
cat $output | grep bw= |grep  read  | awk '{print substr($4,4,length($4)-4)}'
echo "\nread iops:"
cat $output | grep iops= |grep  read  | awk '{print substr($5,6,length($5)-6)}'

