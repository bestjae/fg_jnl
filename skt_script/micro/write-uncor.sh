#!/bin/bash
#$1 = dev name
#$2 = start-block
#$3 = block-count

dev_name=$1
argc=$#

if [ $argc -lt 3 ]
then
    echo "Usage : ./write-uncor.sh [device] [start block] [block count]"
    exit 1
fi

if [ "/dev/nvme0" == "$1" ]; then
    nvme write-uncor $1 --namespace-id=1 --start-block=$2 --block-count=$3
else
    nvme write-uncor $1  --start-block=$2 --block-count=$3
fi

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "${dev_name} write-uncor pass"
    exit 0
else
    echo "${dev_name} write-uncor fail"
    exit 1
fi
