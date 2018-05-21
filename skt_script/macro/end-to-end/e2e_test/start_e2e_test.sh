#!/bin/bash

argc=$#
dev_name=$1
test_count=$2
script_dir=$(cd "$(dirname "$0")" && pwd)

if [ $argc -lt 1 ]; then
    echo "Usage : ./start_e2e_test.sh [device]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

#Make log directory
mkdir ${script_dir}/../../../log/e2e

for (( script_num=1; script_num<=6; script_num++ )) ;do
    echo "End-to-End Protection test ${i} start..."
    ${script_dir}/e2e_test_"0"${script_num}.sh $dev_name $test_count| ${script_dir}/write_log.sh ${script_dir}/../../../log/e2e/e2e_test_"0"${script_num}
    echo "End-to-End Protection test ${i} end..."
    echo -e "\n"
done
