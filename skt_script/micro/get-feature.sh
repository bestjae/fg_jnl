#!/bin/bash
# $1=/dev/device_name $2=data length
# when fid = 3, LBA range type, we can use data-length field

fid=1
argc=$#

if [ $argc -lt 2 ]
then
    echo "Usage : ./get-feature.sh [device] [data-length]"
    exit 1
fi

for fid in {1..11}
do
    echo "------ fid = $fid ------"
    if [ $fid -eq 3 ]; then
        nvme get-feature $1 --feature-id=$fid --data-len=$2
    else
        nvme get-feature $1 --feature-id=$fid
    echo "------------------------"
fi
done

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "get-feature command pass"
    exit 0
else
    echo "get-feature command fail"
    exit 1
fi
