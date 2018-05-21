#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1


if [ $argc -lt 1 ]; then
    echo $firmware_ver `nvme list | grep '/dev/nvme0' | awk '{print $15}'`
    exit 0
fi

echo $firmware_ver `nvme list | grep $dev_name | awk '{print $15}'`

