#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : make_ssh.sh
# Purpose : 
# Creation Date : 2017-02-05
# Last Modified : 2017-02-05 05:59:49
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

#for((;1;))
#do
#	line=`virsh list | wc -l`
#	if [ $line -eq 3 ]; then
#		echo "scp finish"
#		virsh start ubuntu
#		break
#	fi 
#	tput cuu 1
#	echo -e "\rchecking to finish installing vm"
#done
#


if [ $# -lt 1 ]; then
	echo "[ssh >> kernel.sh]"
	sshpass -p32111890 ssh -o StrictHostKeyChecking=no root@192.168.122.11 ./kernel.sh
elif [ $1 = 'all' ] ; then 
	echo "[ssh >> kernel_all.sh]"
	sshpass -p32111890 ssh -o StrictHostKeyChecking=no root@192.168.122.11 ./kernel_all.sh
fi

echo -e "attamp ssh + kernel.sh"

for((i=0;;i++))
do
	if [ $((i%10)) -eq 0 ] ; then
		printf "\r[          ]"
		printf "\r[."
	else
		printf "."	
	fi

	line=`virsh list | wc -l`
	if [ $line -eq 4 ]; then
		sleep 10
		sshpass -p32111890 ssh -o StrictHostKeyChecking=no root@192.168.122.11
		break
	fi 
	sleep 1
done
