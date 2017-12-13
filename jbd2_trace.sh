#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : jbd2_trace.sh
# Purpose : 
# Creation Date : 2017-07-04
# Last Modified : 2017-07-04 13:23:26
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

/home/bestjae/NVTX/ramdisk/on_rdk.sh

 check_rdk() {
echo "Checking RDK......"
echo "Doing DD...."
dd if=/dev/rdk of=rdk.img bs=512 count=1048576

echo "Doing XXD 1 ...."
xxd rdk.img > rdk1.xxd

#echo "sleep 40s..."
#sleep 40

#echo "Doing XXD 2 ...."
#xxd rdk.img > rdk2.xxd

echo "rdk1 jbd block : `cat rdk1.xxd | grep "c03b 3998" | wc -l`" 
#echo "rdk2 jbd block : `cat rdk2.xxd | grep "c03b 3998" | wc -l`" 

}

check_rdk
echo "Doing For echo..."

rm rdk.img > /dev/null 2> /dev/null
rm rdk1.xxd > /dev/null 2> /dev/null

echo "create Files..."
for ((i=0;i<100000;i++))
do 
	dd if=/dev/urandom of=/home/bestjae/mnt/random${i}.txt bs=512 count=8 > /dev/null 2> /dev/null
done
check_rdk

echo "mv Files..."
for ((i=0;i<100000;i++))
do 
	mv /home/bestjae/mnt/random${i}.txt /home/bestjae/mnt/test${i}.txt 
done
check_rdk

echo "delete Files..."
for ((i=0;i<100000;i++))
do 
	rm /home/bestjae/mnt/test${i}.txt
done
check_rdk
