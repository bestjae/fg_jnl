#!/bin/bash

argc=$#
dev_name=$1
firm_path=$2
test_count=$3
script_dir=$(cd "$(dirname "$0")" && pwd)

if [ $argc -lt 2 ]; then
    echo "Usage : ./start_firmware_test.sh [device] [firmware_path]"
    ${script_dir}/../../micro/input_error_exit.sh
fi

#Make log directory
mkdir ${script_dir}/../../log/firmware

echo "firmware activate option -- action 1 test start..."
${script_dir}/action1.sh $dev_name $firm_path $test_count | ${script_dir}/write_log.sh ${script_dir}/../../log/firmware/action1
echo "firmware activate option -- action 1 test end..."
echo -e "\n"

echo "firmware activate option -- action 0,2 test start..."
${script_dir}/action02.sh $dev_name $firm_path $test_count | ${script_dir}/write_log.sh ${script_dir}/../../log/firmware/action02
echo "firmware activate option -- action 0,2 test end..."
echo -e "\n"

echo "firmware power cycle test start..."
${script_dir}/power_cycle_test.sh $dev_name $firm_path $test_count | ${script_dir}/write_log.sh ${script_dir}/../../log/firmware/power_cycle_test
echo "firmware power cycle test end..."
echo -e "\n"

echo "firmware invalid slot test start..."
${script_dir}/slot_test.sh $dev_name $firm_path $test_count | ${script_dir}/write_log.sh ${script_dir}/../../log/firmware/slot_test
echo "firmware invalid slot test end..."
echo -e "\n"
