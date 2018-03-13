obj-m		:= mod.o

CC		:= gcc

KDIR		:= /usr/src/linux-4.1

PWD		:= $(shell pwd)


default:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

clean:
	rm -rf *.ko
	rm -rf *.mod.*
	rm -rf *.cmd
	rm -rf .tmp*
	rm -rf *.o
