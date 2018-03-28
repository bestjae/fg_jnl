#! /bin/bash 
#
# Copyright(c) 2016 All rights reserved by Yongjae Choi. 
# 
# File Name : module.sh
# Purpose : 
# Creation Date : 2018-03-22
# Last Modified : 2018-03-22 14:18:51
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

make

rmmod proc

insmod proc.ko
