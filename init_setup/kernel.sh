#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : kernel.sh
# Purpose : 
# Creation Date : 2017-01-03
# Last Modified : 2017-12-13 19:49:16
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
sudo wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.10.tar.xz 
#
#sudo tar -xvf linux-4.9*
#
#popd
#

exit 1

if [ $# -lt 1 ]; then

	echo "Usage : $0 [kernel mode naming]"
	exit 1
fi


###### Check Your Kernel Version ######

pushd /usr/src/linux-4.9/ 

sed -e "s/bestjae\ kernel.*mode/bestjae\ kernel\-${1}-mode/g" init/main.c > main.tmp
mv main.tmp init/main.c 


make -j 32

make modules

make modules_install

make install

popd
