#!/bin/bash
argc=$#
dev_name=$1

if [ $argc -lt 1 ]; then
    echo "Usage : ./reset.sh [dev_name]"
    exit 1
fi

nvme reset $dev_name

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "${dev_name} reset command success"
    exit 0
else
    echo "${dev_name} reset command fail"
    exit 1
fi
