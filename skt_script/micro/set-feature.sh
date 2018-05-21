#!/bin/bash
#$1 = dev name 

nvme set-feature $1 --feature-id=$2

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "$1 set-feature command pass"
    exit 0
else
    echo "$1 set-feature command fail"
    exit 1
fi
