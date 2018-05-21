#!/bin/bash

argc=$#
dev_name=$1
namespace_id=$2

if [ $argc -lt 2 ]; then
    echo "Usage : ./flush.sh [device] [namespace_id]"
    exit 1
fi

nvme flush $dev_name -n $namespace_id

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "Flush: success, ${dev_name}n${namespace_id}"
    exit 0
else
    echo "Flush: fail, ${dev_name}n${namespace_id}"
    exit 1
fi
