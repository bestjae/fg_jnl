#!/bin/bash
#$1 = dev name 

#nvme write-zeroes $1 --start-block=$2 --block-count=$3
#
#ret=`echo $?`
#if [ $ret -eq 0 ]; then
#    echo "pass"
#else
#    echo "fail"
#fi

argc=$#
dev_name=$1
sector_size=512
start_block=$2
request_size=$3  
write_size=$(($sector_size*$request_size))
block_count=`expr ${request_size} - 1`


if [ $argc -lt 3 ]; then
    echo "Usage : ./write-zeroes.sh [dev_name] [start block] [request_size(sector)] "
    exit 1
fi

dd if=/dev/zero of=./write_zero.dat count=$request_size oflag=direct > /dev/null 2> /dev/null
nvme write $dev_name --data=./write_zero.dat --data-size=$write_size --block-count=${block_count} --start-block=$start_block 
#nvme write $dev_name --data=./write_data.dat --data-size=$write_size --start-block=$start_block --block-count=$block_count 

ret=`echo $?`

if [ $ret -ne 0 ]; then
	echo "${dev_name} write-zeros command fail"
	exit 1
fi

