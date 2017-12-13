#! /bin/bash 
#
# Copyright(c) 2016 All rights reserved by Yongjae Choi. 
# 
# File Name : init.sh
# Purpose : init setting after install OS.
# Creation Date : 2017-01-03
# Last Modified : 2017-07-06 23:58:18
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#

# Check Sudo User
USER=`whoami`
if [ "$USER" != "root" ] ; then
	echo "ERROR : Not Sudo User, Please Run by Sudo User"
	exit 1	
fi

# Install Basic programs
apt-get install ssh -y
apt-get install vim -y
apt-get install git -y
apt-get install ctags cscope

# Install Package for Kernel Compile
sudo apt-get install build-essential libncurses5 libncurses5-dev bin86 kernel-package -y
sudo apt-get install libssl-dev -y

# Install coding Language
apt-get install g++ -y
apt-get install nodejs -y

# Install JAVA 
apt-get install software-properties-common python-software-properties -y
apt-add-repository ppa:webupd8team/java -y
apt-get update
apt-get install oracle-java8-installer -y

# Setup Configure
cp -r vim /etc/
cp -r wuye.vim /usr/share/vim/vim74/colors/ 
#cp -r ./bashrc ~/.bashrc 
#cp -r ./bash_color ~/.bash_color
#mkdir /home/data/
#tail -n2 fstab >> /etc/fstab
#
#echo "ClientAliveInterval 180" >> /etc/ssh/sshd_config
#echo "ClientAliveCountMAX 9000" >> /etc/ssh/sshd_config


# Additional, You must be set network configure.
# and exec `sudo passwd su` for ssh root login.
