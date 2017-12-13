#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : jbd2_trace.sh
# Purpose : 
# Creation Date : 2017-07-04
# Last Modified : 2017-10-20 14:25:38
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#




function create_file()
{
	echo "----------------------------------------------------"
	beginTime=$(date +%s%N)
	echo "create Files...$(($file_size * 4))k * ${file_num}"
	echo "[----------]"
	tput cuu1 && tput cuf 1
	for ((i=0;i<$file_num;i++))
	do 
		dd if=/dev/urandom of=/home/bestjae/mnt/random${i}.txt bs=512 count=$((8 * $file_size)) > /dev/mull 2> /dev/null
		
		if [ $(( $i % $(( $file_num / 10)) )) -eq 0 ]; then
			printf "*"	
		fi
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

#file_size=1		# num * 4k
#file_num=100000
#create_file


file_size=10		# num * 4k
file_num=10000
create_file



file_size=100		# num * 4k
file_num=1000
create_file


file_size=1000		# num * 4k
file_num=100
create_file


file_size=10000		# num * 4k
file_num=10
create_file

echo "Sync ..."
sync
