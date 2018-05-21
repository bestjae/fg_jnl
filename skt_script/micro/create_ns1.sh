#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
request_size=$2

if [ $argc -lt 2 ]; then
    echo "Usage: ./create_ns.sh [device] [request_size (sector size)]"
    exit 1
fi

nvme create-ns $dev_name -s $request_size 

ret=`echo $?`
${script_dir}/validity_check.sh $0 $ret $dev_name
