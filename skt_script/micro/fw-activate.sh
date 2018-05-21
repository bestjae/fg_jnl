#!/bin/bash
# $1 = firmware activate action (0,1,2)
# $2 = firmware slot (2,3)

dev_name=$1
action=$2
slot=$3
argc=$#

if [ $argc -lt 3 ]; then
    echo "Usage : ./fw-actiave.sh [device] [firmware action] [firmware slot]"
    exit 1
fi

nvme fw-activate $dev_name --action=$action --slot=$slot

ret=`echo $?`
if [ $ret -eq 11 ]; then
    echo "${dev_name} fw-activate command success"
    exit $ret
else
    echo "${dev_name} fw-activate command fail"
    exit $ret

fi
