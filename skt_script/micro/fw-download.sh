#!/bin/bash
# $1 = fimrware가 위치하는 절대 경로
#

dev_name=$1
firmware=$2
argc=$#

if [ $argc -lt 2 ]; then
    echo "Usage : ./fw-download.sh [device] [firmware path]"
    exit 1
fi

nvme fw-download $dev_name -f $firmware
ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "${dev_name} fw-download command success"
    exit 0
else
    echo "${dev_name} fw-download command fail"
    exit 1
fi
