#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
del_namespace_id=$2

if [ $argc -lt 2 ]; then
    echo "Usage : ./delete_ns.sh [device] [del_namespace_id]"
    exit 1
fi

global_ns=`cat ${script_dir}/ns`

nvme delete-ns $dev_name -n $del_namespace_id 

ret=`echo $?`

${script_dir}/validity_check.sh $0 $ret $dev_name $del_namespace_id
