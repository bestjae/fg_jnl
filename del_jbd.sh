#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : jbd2_trace.sh
# Purpose : 
# Creation Date : 2017-07-04
# Last Modified : 2017-07-04 13:47:41
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#
echo "delete Files..."
for ((i=0;i<10000;i++))
do 
	rm /home/bestjae/mnt/test${i}.txt
done
