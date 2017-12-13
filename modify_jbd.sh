#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : jbd2_trace.sh
# Purpose : 
# Creation Date : 2017-07-04
# Last Modified : 2017-07-04 13:46:00
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

echo "mv Files..."
for ((i=0;i<10000;i++))
do 
	mv /home/bestjae/mnt/random${i}.txt /home/bestjae/mnt/test${i}.txt 
done
