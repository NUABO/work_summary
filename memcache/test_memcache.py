# coding=utf-8
# test_memcache.py

#服务端启动 memcached -d -p 11211  -u memcached -m 1024 -c 64 -f 1.25 -I 4M
import memcache
#from dbgp.client import brk
#brk(host="191.168.45.215", port=51304)

#servers="unix:port"
#servers="inet:ipv4:port"
#servers="ipv4:port"
#servers="inet6:ipv6:port"
# [('127.0.0.1:11211', 1),('191.168.45.74:11211', 2)]  带有权重的，默认权重为1，如果为2时分配到的概率要大一倍
#['127.0.0.1:11211','191.168.45.74:11211']#研究一下多服务器的情况
mc = memcache.Client(['127.0.0.1:11211','191.168.45.74:11211'], debug=0)

mc.set("some_key", "Some value")
value = mc.get("some_key")

mc.set("some_key", "Some value 123") #update
value = mc.get("some_key")

mc.set("some_key", [1,2]) 
mc.append("some_key", 1)#??????
mc.get("some_key")

mc.set("some_key", (1,2)) 
mc.get("some_key")

mc.set("some_key", {'key1':'1','key2':'2'}) 
print mc.get("some_key")


mc.set("another_key", 3)
mc.delete("another_key")
value = mc.get("another_key") #None 不会报错

ret = mc.add("some_key_2", "add value") #类似set,当key存在时，返回False,不覆盖
value = mc.get("some_key_2")

print  mc.append("some_key_2", " append value") #当key不存在时，返回False,不添加
value = mc.get("some_key_2")  #add value append value
print value
mc.delete("some_key_2") #返回1
mc.delete("some_key_2") #还是返回1

mc.set("key", 5)   #不能为负值 5 或 ‘5’ note that the key used for incr/decr must be a string.
mc.incr("key")
print mc.get("key") #2
mc.decr("key")
print mc.get("key") #1

#cas
mc.check_key("key") #没有报异常就是好的，没有返回值

mc.debuglog('ok') #不知写到哪去

notset_keys = mc.set_multi({'key1' : 'val1', 'key2' : 'val2'})
print mc.get("key1")

print mc.get_multi(['key1', 'key2']) == {'key1' : 'val1', 'key2' : 'val2'} #True
mc.delete_multi(['key1', 'key2'])
mc.get_multi(['key1', 'key2']) == {} #True

mc.set_multi({'k1' : 1, 'k2' : 2}, key_prefix='pfx_')
print mc.get("pfx_k1") #1
mc.get_multi(['k1', 'k2', 'nonexist'], key_prefix='pfx_') == {'k1' : 1, 'k2' : 2} #True
mc.set_multi({42: 'douglass adams', 46 : 'and 2 just ahead of me'}, key_prefix='numkeys_')
mc.get_multi([46, 42], key_prefix='numkeys_') == {42: 'douglass adams', 46 : 'and 2 just ahead of me'}#True

print mc.get("numkeys_46")

print mc.disconnect_all() #断开所有连接
mc.set("some_key", "Some value")#会重新建立连接
mc.flush_all() #清楚所有数据,key也清空
print mc.add("numkeys_46",'123')  #True


#forget_dead_hosts
#get_slabs
#get_stats

#print mc.get_slabs()
#print mc.get_stats()

mc.set("some_key", "Some value")
mc.prepend("some_key",'123 ') #类似append，在前面添加
print mc.get("some_key") #123 Some value

print mc.replace("some_key",'123')#替换，key不存在返回False
print mc.get("some_key") #123

#set_servers

#mc = memcache.Client(['127.0.0.1:11211'], debug=0,cache_cas = True)
#mc.cas("some_key", "Some value")
#mc.gets("some_key")
#mc.cas("some_key", "Some value")









