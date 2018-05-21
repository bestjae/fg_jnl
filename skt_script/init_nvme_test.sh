#! /bin/bash 

dev_name=$1
argc=$#
script_dir=$(cd "$(dirname "$0")" && pwd)

if [ $argc -lt 1 ]; then
	echo "Usage : ./init_namespace.sh [device]"
	exit 1
fi


${script_dir}/micro/delete_ns1.sh $dev_name 1
${script_dir}/micro/create_ns1.sh $dev_name 3000000
${script_dir}/micro/attach_ns1.sh $dev_name 1 1 

python ${script_dir}/quarch/power_off.py
python ${script_dir}/quarch/power_on.py
${script_dir}/quarch/rescan_retry.sh

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo 1 > ${script_dir}/micro/ns 
fi

