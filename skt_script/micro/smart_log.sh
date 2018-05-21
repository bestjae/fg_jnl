#!/bin/bash

argc=$#
dev_name=$1
namespace_id=$2

if [ $argc -lt 2 ]; then
	echo "Usage : ./smart_log.sh [device] [namespace_id] "
	exit 1
fi

nvme smart-log $dev_name --namespace-id=$namespace_id 

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "smart-log command pass"
    exit 0
else
    echo "smart-log command fail"
    exit 1
fi
