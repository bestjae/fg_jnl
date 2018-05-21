#!/bin/bash

dev_name=$1
argc=$#

if [ $argc -lt 1 ]; then
    echo "Usage : ./list-ns.sh [dev_name]"
    exit 1
fi

nvme list-ns $dev_name --all

ret=`echo $?`
if [ $ret -eq 0 ]; then
    exit 0
else
    exit 1
fi
