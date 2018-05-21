#!/bin/bash

argc=$#
dev_name=$1
test_count=$2
script_dir=$(cd "$(dirname "$0")" && pwd)

if [ $argc -lt 1 ]; then
    echo "Usage : ./start_format_test.sh [device]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

#Make log directory
mkdir ${script_dir}/../../../log/dsm

for (( script_num=1; script_num<=5; script_num++ )) ;do
    echo "DSM test ${script_num} start..."
    ${script_dir}/dsm_test_"0"${script_num}.sh $dev_name $test_count  $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/dsm/dsm_test_"0"${script_num}
	echo -e "\n"
    echo "DSM test ${script_num} end..."
    echo -e "\n"
done
