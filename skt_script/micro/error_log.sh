#!/bin/bash

argc=$#
dev_name=$1
log_ent=$2
namespace_id=$3

if [ $argc -lt 2 ]
then
    echo "Usage : ./error_log [device] [number of entries] [namespace id]"
    exit 1
fi

nvme error-log $dev_name --namespace-id=$namespace_id --log-entries=$log_ent > /dev/null

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "error-log command pass"
    exit 0
else
    echo "error-log command fail"
    exit 1
fi
