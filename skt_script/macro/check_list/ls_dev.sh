# !/bin/bash

argc=$#
dev_name=$1

if [ $argc -lt 1 ]; then
    echo "Usage : ./ls_dev.sh [device]"
    exit 1
fi

if [ ! -e $dev_name ]; then
    echo "$dev_name detect fail"
    exit 1
else
    echo "$dev_name detect success"
fi
