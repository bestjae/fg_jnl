#!/bin/bash

dev_name=$1
argc=$#

if [ $argc -lt 1 ]; then
    echo "Usage : ./list-ns.sh [dev_name]"
    exit 1
fi

nvme list-ns $dev_name 

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "list-ns command pass"
    exit 0
else
    echo "list-ns command fail"
    exit 1
fi
