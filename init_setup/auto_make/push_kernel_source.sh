#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : push_kernel_source.sh
# Purpose : 
# Creation Date : 2017-01-24
# Last Modified : 2017-02-08 14:09:55
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

ami=`whoami`
compile_type=all


if [ $ami != 'root' ]; then
	echo "please exac by root"
	exit 1
fi

printf "Do you really sync jbd2 directory? [y/n] : "
read a

if [ $a = 'n' ]; then
	echo "Stop sync kernel code..."
	exit 1
fi


function push_code(){
	local file=$1
	local target_dir=$2
	sshpass -p32111890 scp -o StrictHostKeyChecking=no ~/linux/$file root@192.168.122.11:~/linux/$target_dir

	echo "[ Send : $1 -> $2 ]"
}

#  /fs/jbd2/*c
push_code fs/jbd2/*.c fs/jbd2/
#  init/main.c
push_code init/main.c init/
#  /fs/*c
push_code fs/*.c fs/
#  include/linux/*.h
push_code include/linux/*.h include/linux/

push_code include/asm-generic/*.h include/asm-generic/

printf "select compile_type : [all] : "
read a

./make_ssh.sh $a

