#!/bin/bash

argc=$#
dev_name=$1
log_id=$2
log_len=$3
namespace_id=$4

if [ $argc -lt 4 ]; then
	echo "Usage : ./get_log.sh [device] [log-id] [log-len] [namespace id]"
	exit 1
fi

nvme get-log $dev_name --log-id=$log_id --log-len=$log_len --namespace-id=$namespace_id 

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "get-log command pass"
    exit 0
else
    echo "get-log command fail"
    exit 1
fi
