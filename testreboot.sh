#!/bin/bash
#
#md5file and umount
md5file(){
umount /home/cbd1
#umount /home/cbd2
sleep 1s
mount /dev/sdb1 /home/cbd1
#mount /dev/sdc1 /home/cbd2
echo "remount done"
for Lun in 1 
do    
 	 for File in 1 2 3 4
		do
		echo "$(date)"
		a=`md5sum /home/cbd$Lun/$File|cut -d ' ' -f1`
	##	b="f590ff5ecc9c27864c98583230667c88"  3.3Giso
		b="17643c29e3c4609818f26becf76d29a3" ### 1.5Giso
		if [ "$a" = "$b" ]
		then
		    echo "cbd$Lun/$File": "'$a' eq '$b'"
		let 'File++'
		else
		    echo "cbd$Lun/$File": "'$a' ne '$b'"
		   # kill 0
		 exit 1
		fi
			
	done

let 'Lun++'
done
sleep 1s
umount /home/cbd1
#umount /home/cbd2
echo "umount done"
}


judgestatus(){
#costor controller list | grep -A 10 'Names' | awk -F\\\" '{print $2}' > ./getvid.log
costor controller list | grep -A 10 'Names' | awk -F\\\" '{print $2}'| sed '/^[Names].*/d'|tr -s '\n' > ./getvid.log
while read getvid; 
do
#costor controller inspect --name $getvid |grep "Status" | awk -F "[:]" '{print $2}' |grep -v "," > ./getstatus.log
costor controller inspect --name $getvid |grep "Status" | awk -F "[: ,]" '{print $3}' > ./getstatus.log
grep -q "2" ./getstatus.log
if [[ $? -eq 0 ]]; then
  echo "wait for volumehealth"
  return 1
  else
 echo health
 fi
done < ./getvid.log
}

volumehealth(){
while true
do
judgestatus
if [[ $? -eq 1 ]];then
sleep 120s
else
echo "volume is health" "$(date)"
break
fi
done
}


i=1
while [ $i -le 2000 ]
do
  if ping -c 3 192.168.3.205 > /dev/null && ping -c 3 192.168.3.206 > /dev/null && ping -c 3 192.168.3.207 > /dev/null
  then
#    rm /home/cbd1/*.file
#    rm /home/cbd2/*.file
#    rm /home/cbd3/*.file
#    rm /home/cbd4/*.file
     md5file
     /usr/bin/expect <<-EOF
set timeout 5
spawn ssh root@192.168.3.205
expect {
    "Connection refused" exit
    "Name or service not known" exit
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "123456\r";exp_continue}
    "Last login" {send " reboot\n"}
}

expect eof
exit
EOF
     echo "$i" "$(date)"| tee -a /home/reboot.log
	sleep 240s
     volumehealth
 /usr/bin/expect <<-EOF
set timeout 5
spawn ssh root@192.168.3.205
expect {
    "Connection refused" exit
    "Name or service not known" exit
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "123456\r";exp_continue}
    "Last login" {send " systemctl start cosrv gateway costor-controller costor-engine cmonitor-server cmonitor-agent\n"}
}

expect eof
exit
EOF

        echo "$i"
	sleep 30s
     let 'i++'
        if ping -c 3 192.168.3.205 > /dev/null && ping -c 3 192.168.3.206 > /dev/null && ping -c 3 192.168.3.207 > /dev/null
 	 then
#             rm /home/cbd1/*.file
#             rm /home/cbd2/*.file
#             rm /home/cbd3/*.file
#             rm /home/cbd4/*.file
		md5file
           /usr/bin/expect <<-EOF
set timeout 5
spawn ssh root@192.168.3.206
expect {
    "Connection refused" exit
    "Name or service not known" exit
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "123456\r";exp_continue}
    "Last login" {send " reboot\n"}
}

expect eof
exit
EOF
           echo "$i" "$(date)" | tee -a /home/reboot.log
		sleep 240s
           volumehealth
	   /usr/bin/expect <<-EOF
set timeout 5
spawn ssh root@192.168.3.206
expect {
    "Connection refused" exit
    "Name or service not known" exit
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "123456\r";exp_continue}
    "Last login" {send " systemctl start cosrv gateway costor-controller costor-engine cmonitor-server cmonitor-agent\n"}
}

expect eof
exit
EOF

        	echo "$i"
		sleep 30s
           let 'i++'
 	else
	   echo error
 	   echo "$i" | tee -a /home/reboot.log
         break
        fi
		if ping -c 3 192.168.3.205 > /dev/null && ping -c 3 192.168.3.206 > /dev/null && ping -c 3 192.168.3.207 > /dev/null
         	then
#            		rm /home/cbd1/*.file
#           		rm /home/cbd2/*.file
#            		rm /home/cbd3/*.file
#           	 	rm /home/cbd4/*.file
  			md5file
			/usr/bin/expect <<-EOF
set timeout 5
spawn ssh root@192.168.3.207
expect {
    "Connection refused" exit
    "Name or service not known" exit
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "123456\r";exp_continue}
    "Last login" {send " reboot\n"}
}

expect eof
exit
EOF
			echo "$i" "$(date)" | tee -a /home/reboot.log
			sleep 240s
			volumehealth
			/usr/bin/expect <<-EOF
set timeout 5
spawn ssh root@192.168.3.207
expect {
    "Connection refused" exit
    "Name or service not known" exit
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "123456\r";exp_continue}
    "Last login" {send " systemctl start cosrv gateway costor-controller costor-engine cmonitor-server cmonitor-agent\n"}
}

expect eof
exit
EOF

        		echo "$i"
			sleep 30s
			let 'i++'  
    		else  
			echo error  
          	 	echo "$i" | tee -a /home/reboot.log
        	 break
       		 fi
  else
     echo error
     echo "$i" | tee -a /home/reboot.log
  break
  fi
done
