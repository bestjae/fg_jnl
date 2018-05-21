#!/bin/bash

argc=$#
dev_name=$1
sector_size=512
start_block=$2
request_size=$3  
read_size=$(($sector_size*$request_size))
block_count=`expr $request_size - 1`


if [ $argc -lt 3 ]; then
    echo "Usage : ./read.sh [dev_name] [start block] [read_size] "
    exit 1
fi

nvme read $dev_name -z ${read_size} -c ${block_count} -s ${start_block} -d read_data.dat 

ret=`echo $?`
if [ $ret -ne 0 ]; then
	echo "${dev_name} write command fail"
	exit 1	
fi
