#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
attach_name_id=$2
controller_id=$3


if [ $argc -lt 2 ]; then
	echo "Usage : ./attach-ns.sh [device] [attach_namespace_id] [controller_id]"
	exit 1
fi

nvme attach-ns $dev_name -n $attach_name_id -c $controller_id
ret=`echo $?`

${script_dir}/validity_check.sh $0 $ret $dev_name $attach_name_id
