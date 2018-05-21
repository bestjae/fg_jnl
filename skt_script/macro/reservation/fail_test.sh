#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)

argc=$#
dev_name=$1
filename=$2
ret=$?

#check 1
nvme list > ${script_dir}/result.txt &
${script_dir}/../../macro/check_list/check_reboot.sh nvme list
ret=`echo $?`

if [ $ret -eq 1 ]; then
    echo "$2 test fail"
    sleep 20
    reboot
    exit 1
fi

#check 2
check=`cat ${script_dir}/result.txt`
not_exist="No NVMe devices detected."

if [ "$check" = "$not_exist" ] ; then
	echo "NVMe dead"
    echo "$2 test fail"
	exit 1
fi

echo "$2 test success"
exit 0

