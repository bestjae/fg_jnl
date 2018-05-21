#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1

if [ $argc -lt 1 ]; then
	echo "Usage : ./fsck.sh [device] " 
	exit 1
fi

echo "fsck checking test..."
#fsck ${dev_name} > /dev/null 2> /dev/null
fsck ${dev_name}

ret=`echo $?`

if [ $ret -eq 0 ] ;
then
    echo "fsck pass"
    exit 0
else
    echo "fsck fail"
    exit 1

fi
