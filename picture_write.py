#!/usr/bin/env python

from os import system
from time import sleep

cmd="dd if=/dev/zero of=pic.jpg bs=1k count=209"
i=0
system("rm -rf /cluster/volume1/test")
system("mkdir /cluster/volume1/test")
while(1):
    system(cmd)
    cmd_cp ="cp pic.jpg /cluster/volume1/test/pic_%07d.ipg" %i
    system(cmd_cp)
    sleep(0.066)
    i=i+1