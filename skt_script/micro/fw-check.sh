#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
fw_dir=$2

if [ $argc -lt 2 ]; then
	echo "Usage : ./fw-check.sh [device] [fw_dir]"
	exit 1
fi

tar -xvf $fw_dir > /dev/null

for line in $(cat fwHeader.bin)
do
    fw_bin=`cut -b24-32 fwHeader.bin`
done

i=0

nvme list > list.txt

while read line; do
	if [ $i -eq 2 ]; then
		cur_fw=`echo $line | cut -d'+' -f2`
		cur_fw=`echo $cur_fw | cut -d' ' -f3`
	fi
	i=`expr $i + 1`
done < list.txt

if [ "$fw_bin" == "$cur_fw" ]; then
    echo "Firmware update success"
    echo "current firmware :" $cur_fw ", target firmware :" $fw_bin
    exit 0
else
    echo "Firmware update fail" 
    echo "current firmware :" $cur_fw ", target firmware :" $fw_bin
        exit 1
fi
