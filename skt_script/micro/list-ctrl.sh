#!/bin/bash
#$1 = dev name 

nvme list-ctrl $1 --namespace-id=$2

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "list-ctrl command pass"
    exit 0
else
    echo "list-ctrl command pass"
    exit 1
fi
