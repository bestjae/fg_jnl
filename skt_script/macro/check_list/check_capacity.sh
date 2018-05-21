#! /bin/bash 

device=$1
argc=$#

if [ $argc -lt 1 ] ; then 
	echo "Usage : ./check_capacity.sh [device]"
	exit 1
fi 

dev_byte=`fdisk -l | grep $1 | head -n 1 | awk '{print $5}'` 2> /dev/null
echo "$dev_byte"

