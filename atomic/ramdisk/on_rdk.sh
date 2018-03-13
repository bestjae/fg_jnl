#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : on_rdk.sh
# Purpose : 
# Creation Date : 2017-02-08
# Last Modified : 2018-02-27 17:39:55
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

echo "<< Umount mnt >>"
umount ~/mnt
echo "<< Remove Module ramdisk >>"
rmmod ramdisk

echo "<< Make Ramdisk >>"
make clean
make 

echo "<< Install Module Rdk >>"
insmod ramdisk.ko

echo "<< Make filesystem ext4 >>"
mkfs.ext2 /dev/rdk

echo "<< Mount mnt >>"
mount /dev/rdk ~/mnt/

