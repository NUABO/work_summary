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


c��ȷ��setlinux�رգ�������setenforce 0����ִ�С� Ĭ�ϵģ�SELinux��ֹ�����϶�Samba�������ϵĹ���Ŀ¼����д��������ʹ����smb.conf�����������������       /usr/bin/setenforce �޸�SELinux��ʵʱ����ģʽ  

setenforce 1 ����SELinux ��Ϊenforcingģʽ

setenforce 0 ����SELinux ��Ϊpermissiveģʽ  

���Ҫ���׽���SELinux ��Ҫ��/etc/sysconfig/selinux�����ò���selinux=0 ��������/etc/grub.conf������������

  /usr/bin/setstatus -v  