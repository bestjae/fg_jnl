#!/bin/bash

argc=$#
dev_name=$1

if [ $argc -lt 1 ]; then
	echo "Usage : ./fw_log.sh [device] "
	exit 1
fi


nvme fw-log $dev_name

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "${dev_name} fw-log command success"
    exit 0
else
    echo "${dev_name} fw-log command fail"
    exit 1
fi
