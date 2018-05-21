#!/bin/bash
#$1 = dev name

nvme smart-log-add $1 

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "smart-log-add command pass"
    exit 0
else
    echo "smart-log-add command fail"
    exit 1
fi
