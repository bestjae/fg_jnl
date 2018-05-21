#!/bin/bash
#$1 = dev name

nvme list $1  

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "list command pass"
    exit 0
else
    echo "list command fail"
    exit 1
fi
