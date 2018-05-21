#!/bin/bash
#$1 = dev name 

sector_size=512
request_size=$2  
write_size=$(($sector_size*$request_size))
argc=$#
    
if [ $argc -lt 3 ]; then
	echo "Usage : ./compare.sh [device] [request_size] [start_block]"
	exit 1
fi
echo "write size : $write_size"

dd if=/dev/zero of=./write_data.dat count=$2 oflag=direct
nvme compare $1 --start-block=$3 --data-size=$write_size --data=./write_data.dat

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "${dev_name} compare command pass"
    exit 0
else
    echo "${dev_name} compare command fail"
    exit 1
fi
