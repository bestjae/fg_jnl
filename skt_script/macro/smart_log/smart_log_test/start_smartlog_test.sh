#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
test_count=$2

if [ $argc -lt 1 ]; then
    echo "Usage : ./start_smartlog_test.sh [device]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

#Make log directory
mkdir ${script_dir}/../../../log/smart_log

echo "SMART log test start"
${script_dir}/smart_log_test.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/smart_log/smart_log_test
echo "SMART log test end"
echo -e "\n"

echo "SMART log with I/O test start"
${script_dir}/smart_io_test.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/smart_log/smart_io_test
echo "SMART log with I/O test end"
echo -e "\n"

echo "SMART log with NPOR test start"
${script_dir}/smart_npor_test.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/smart_log/smart_npor_test
echo "SMART log with NPOR test end"
echo -e "\n"

echo "SMART log with SPOR test start"
${script_dir}/smart_spor_test.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/smart_log/smart_spor_test
echo "SMART log with SPOR test end"
echo -e "\n"
