#!/bin/bash
#$1 = namespace id

argc=$#

if [ $argc -lt 1 ]
then
    echo "Usage : ./id-ns-char.sh [namespace-id]"
    exit 1
fi


nvme id-ns /dev/nvme0 $1
nvme id-ns /dev/nvme0 $1 --vendor-specific
nvme id-ns /dev/nvme0 $1 --raw-binary
nvme id-ns /dev/nvme0 $1 --human-readable

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "id-ns command pass"
    exit 0
else
    echo "id-ns command fail"
    exit 1
fi
