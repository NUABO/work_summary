1 ¹Ø±Õ·À»ğÇ½

centos 6 

/etc/init.d/iptables stop
chkconfig iptables off

centos 7
systemctl stop  firewalld.service
systemctl disable  firewalld.service

Æô¶¯smb

6:
/etc/init.d/smb stop
chkconfig smb off

7:
systemctl start smb
systemctl enable smb

ÉèÖÃsmbÃÜÂë
smbpasswd -a root