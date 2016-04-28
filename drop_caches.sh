#!/bin/sh

drop_interval=1

#if [ "`cat /etc/rc.local |grep drop_caches.sh`" = "" ] ;then
	#cp $0 /sbin/drop_caches.sh
	#echo >> /etc/rc.local
	#echo "sh /sbin/drop_caches.sh & >/dev/null" >> /etc/rc.local
#fi

while [ true ]
do
	mem_left=`cat /proc/meminfo | grep "MemFree:" |awk {'print $2'}`
	if [ ${mem_left} -le 307200 ]
	then
		echo 1 > /proc/sys/vm/drop_caches
	fi
	sleep $drop_interval
done