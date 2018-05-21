#!/bin/bash

argc=$#
option=$1
dev_name=$2
start_block=$3
block_size=$4


if [ $argc -lt 4 ]; then
    echo "Usage : ./dsm.sh [dev_name] [option(-d, -w, -r)] [start_block] [block_size]"
    exit 1
fi


nvme dsm ${dev_name} ${option} --blocks=${block_size} --slbs=${start_block} > /dev/null 2> /dev/null


ret=`echo $?`

if [ $ret -eq 0 ]; then
    echo "${dev_name} dsm command pass"
else
    echo "${dev_name} dsm command fail"
fi
