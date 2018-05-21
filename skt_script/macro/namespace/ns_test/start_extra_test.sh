#!/bin/bash

argc=$#
dev_name=$1
test_count=$2
script_dir=$(cd "$(dirname "$0")" && pwd)

if [ $argc -lt 2 ]; then
    echo "Usage : ./start_extra_test.sh [device] [test_count]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

for (( script_num=23;script_num<=31;script_num++ )) 
do
    echo "Extra test ${script_num} start..."
    ${script_dir}/ns_test_${script_num}.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/namespace_log/ns_test_${script_num}
    echo "Extra test ${script_num} end..."
    echo -e "\n"
done
