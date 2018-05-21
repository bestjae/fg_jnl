#! /bin/bash 
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
det_namespace_id=$2
controller_id=$3
if [ $argc -lt 3 ]; then
	echo "Usage : ./detach_ns.sh [device] [detach_namespace_id] [controller id]"
	exit 1
fi

nvme detach-ns $dev_name -n $det_namespace_id -c $controller_id

ret=`echo $?`
${script_dir}/validity_check.sh $0 $ret $dev_name $det_namespace_id
