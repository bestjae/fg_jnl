#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : filebench.sh
# Purpose : 
# Creation Date : 2017-01-27
# Last Modified : 2017-02-02 22:22:51
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

sudo apt-get install libtool automake byacc bison flex -y
audo apt-get autoremove -y


wget https://github.com/filebench/filebench/archive/1.4.9.1.tar.gz
tar -xvf 1.4.9.1.tar.gz
pushd ./filebench-1.4.9.1/ 

libtoolize
aclocal
autoheader
automake --add-missing
autoconf

./configure
make
sudo make install
popd
