#!/bin/bash

argc=$#
dev_name=$1
namespace_id=$2
secure_erase=$3
success_str="Success formatting namespace:$namespace_id"

if [ $argc -lt 2 ];
then
    echo "Usage : ./format.sh [device] [namespace id] [secure erase type]"
    exit 1
fi


if [ $argc -eq 3 ];
then
	nvme format $dev_name --namespace-id=$namespace_id --ses=$secure_erase
else
	nvme format $dev_name --namespace-id=$namespace_id 
fi
ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "${dev_name} format command success"
    exit 0
else
    echo "${dev_name} format command fail"
    exit 1
fi
