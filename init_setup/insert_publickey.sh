#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : insert_publickey.sh
# Purpose : 
# Creation Date : 2017-02-05
# Last Modified : 2017-02-05 05:07:23
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#
cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
