#!/bin/bash

argc=$#
dev_name=$1

if [ $argc -lt 1 ]; then
    echo "Usage : ./subsystem-reset.sh [dev_name]"
fi

nvme subsystem-reset $dev_name

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "${dev_name} subsystem-reset command pass"
    exit 0
else
    echo "${dev_name} subsystem-reset command fail"
    exit 1
fi

