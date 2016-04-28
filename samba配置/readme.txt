1 关闭防火墙

centos 6 

/etc/init.d/iptables stop
chkconfig iptables off

centos 7
systemctl stop  firewalld.service
systemctl disable  firewalld.service

启动smb

6:
/etc/init.d/smb stop
chkconfig smb off

7:
systemctl start smb
systemctl enable smb

设置smb密码
smbpasswd -a root


c、确保setlinux关闭，可以用setenforce 0命令执行。 默认的，SELinux禁止网络上对Samba服务器上的共享目录进行写操作，即使你在smb.conf中允许了这项操作。       /usr/bin/setenforce 修改SELinux的实时运行模式  

setenforce 1 设置SELinux 成为enforcing模式

setenforce 0 设置SELinux 成为permissive模式  

如果要彻底禁用SELinux 需要在/etc/sysconfig/selinux中设置参数selinux=0 ，或者在/etc/grub.conf中添加这个参数

  /usr/bin/setstatus -v  