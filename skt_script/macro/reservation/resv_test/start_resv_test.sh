#!/bin/bash

argc=$#
dev_name=$1
test_count=$2
script_dir=$(cd "$(dirname "$0")" && pwd)

#Make log directory
mkdir ${script_dir}/../../../log/reservation

for (( script_num=1;script_num<=5;script_num++ )) ;do
    echo "reservation test 0${script_num} start..."
    ${script_dir}/resv_test_0${script_num}.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/reservation/resv_test"0"${script_num}
    echo "reservation test 0${script_num} end..."
    echo -e "\n"
done


