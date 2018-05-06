#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : jbd2_trace.sh
# Purpose : 
# Creation Date : 2017-07-04
# Last Modified : 2018-05-02 23:01:50
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#




function create_file()
{
	echo "----------------------------------------------------"
	beginTime=$(date +%s%N)
	echo "[----------]"
	tput cuu1 && tput cuf 1
	for ((i=0;i<$file_num;i++))
	do 
		./a.out	${i} > /dev/null
		printf "*"	
	done
	printf "\n"
	
	echo "done.."
	
	endTime=$(date +%s%N) 
	elapsed=`echo "($endTime - $beginTime) / 1000000" | bc` elapsedSec=`echo "scale=6;$elapsed / 1000" | bc | awk '{printf "%.6f", $1}'` 
	
	echo TOTAL: $elapsedSec sec
	echo "----------------------------------------------------"
}

echo "Sync ..."
sync

file_num=5
create_file

echo "Sync ..."
sync
