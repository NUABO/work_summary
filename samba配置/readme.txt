1 �رշ���ǽ

centos 6 

/etc/init.d/iptables stop
chkconfig iptables off

centos 7
systemctl stop  firewalld.service
systemctl disable  firewalld.service

����smb

6:
/etc/init.d/smb stop
chkconfig smb off

7:
systemctl start smb
systemctl enable smb

����smb����
smbpasswd -a root