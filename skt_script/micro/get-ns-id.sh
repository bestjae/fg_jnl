#!/bin/bash
#$1 = block dev name

nvme get-ns-id $1 

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "get-ns-id pass"
    exti 0
else
    echo "get-ns-id fail"
    exit 1
fi
