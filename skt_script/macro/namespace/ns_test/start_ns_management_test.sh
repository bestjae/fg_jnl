#!/bin/bash

argc=$#
dev_name=$1
test_count=$2
script_dir=$(cd "$(dirname "$0")" && pwd)

if [ $argc -lt 2 ]; then
    echo "Usage : ./start_ns_management_test.sh [device] [test_count]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

#Make log directory
mkdir ${script_dir}/../../../log/namespace

for ((script_num=1; script_num<=9; script_num++)) ;do
    echo "Management test 0${script_num} start..."
    ${script_dir}/ns_test_0${script_num}.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/namespace/ns_test_0${script_num}
    echo "Management test 0${script_num} end..."
    echo -e "\n"
done

for (( script_num=10;script_num<=19;script_num++ )) 
do
    echo "Management test ${script_num} start..."
    ${script_dir}/ns_test_${script_num}.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/namespace/ns_test_${script_num}
    echo "Management test ${script_num} end..."
    echo -e "\n"
done
