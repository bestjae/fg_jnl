#!/bin/bash

argc=$#
dev_name=$1
sector_size=512
start_block=$2
request_size=$3
prinfo=$4
write_size=$(($sector_size*$request_size))
script_dir=$(cd "$(dirname "$0")" && pwd)
block_count=`expr ${request_size} - 1`


if [ $argc -lt 4 ]; then
    echo "Usage : ./write-end.sh [dev_name] [start block] [request_size(sector)] [prinfo]"
    exit 1
fi

dd if=/dev/urandom of=./write_data.dat count=$request_size oflag=direct > /dev/null 2> /dev/null

nvme write $dev_name --start-block=$start_block --block-count=$block_count --data-size=$write_size --data=./write_data.dat --metadata-size=8 --metadata=${script_dir}/.meta.img --prinfo=$prinfo -v > /dev/null 2> /dev/null

ret=`echo $?`

if [ $ret -eq 0 ]; then
    echo "${dev_name} write command pass"
    exit 0
else
    echo "${dev_name} write command fail"
    exit 1
fi
