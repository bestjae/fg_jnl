#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : ssh_auto.sh
# Purpose : 
# Creation Date : 2017-02-05
# Last Modified : 2017-03-16 21:56:26
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

target=$1

if [ $# -lt 1 ] ; then
	echo "./ssh_auto.sh [target]"
	echo "ex) ./ssh_auto.sh bestjae@bestjae.com"
	exit 1
fi

scp ./insert_publickey.sh $target:~/
scp $HOME/.ssh/id_rsa.pub $target:~/
ssh $target ./insert_publickey.sh

