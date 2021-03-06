#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : kernel.sh
# Purpose : 
# Creation Date : 2017-01-03
# Last Modified : 2018-05-28 18:43:43
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

#
#sudo apt-get install build-essential libncurses5 libncurses5-dev bin86 kernel-package -y
#sudo apt-get install libssl-dev -y
#
#
#pushd /usr/src 
#
#
#popd
#


make -j 32

make modules

make modules_install

make install

cp /boot/grub/grub.cfg ./grub.old

cp ./grub.cfg /boot/grub/ 

if [ $# -gt 0 ]; then 
	if [ $1 -eq "1" ] ; then
		reboot
	fi 
fi


exit 1
