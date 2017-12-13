#! /bin/bash 
#
# Copyright(c) 2016 All rights reserved by Yongjae Choi. 
# 
# File Name : sd_mnt.sh
# Purpose : 
# Creation Date : 2017-07-10
# Last Modified : 2017-10-20 02:23:52
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#
JOURNAL_MODE=journal

umount ~/mnt/


#mkfs.ext4 /dev/sdb1

echo "mount -o data=$JOURNAL_MODE /dev/sdb1 ~/mnt"
mount -o data=$JOURNAL_MODE /dev/sdb1 ~/mnt
