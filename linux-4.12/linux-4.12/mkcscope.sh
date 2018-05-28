#! /bin/bash 
#
# Copyright(c) 2016 All rights reserved by Yongjae Choi. 
# 
# File Name : mkcscope.sh
# Purpose : 
# Creation Date : 2017-12-14
# Last Modified : 2017-12-14 06:14:47
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#
#!/bin/sh

rm -rf cscope.files cscope.out
find . \( -name '*.c' -o -name '*.cpp' -o -name '*.cc' -o -name '*.h' -o -name '*.s' -o -name '*.S' \) -print > cscope.files 
cscope -i cscope.files

