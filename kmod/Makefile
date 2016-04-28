ifneq ($(KERNELRELEASE),)

mymodule_objs := book.o

obj-m := book.o

else

PWD := $(shell pwd)

KVER ?= $(shell uname -r)

KDIR := /usr/src/kernels/linux-2.6.32.65/

 

all:
	$(MAKE) -C $(KDIR)  M=$(PWD)

clean:
	rm -rf *.mod.c *.mod.o *.ko *.o *.tmp_versions *.order *symvers

endif
