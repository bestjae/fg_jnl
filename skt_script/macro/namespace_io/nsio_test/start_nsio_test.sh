#!/bin/bash

argc=$#
dev_name=$1
test_count=$2
script_dir=$(cd "$(dirname "$0")" && pwd)

EXPECT=`which unbuffer`

if [ !$EXPECT ];then
    	echo "install expect"
	apt-get install expect-dev
fi

if [ $argc -lt 2 ]; then
    echo "Usage : ./start_nsio_test.sh [device name] [test_count]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

#Make log directory
mkdir ${script_dir}/../../../log/namespace_io

for ((script_num=1; script_num<=9; script_num++)) ;do
    echo "Namespace+I/O test 0${script_num} start..."
    unbuffer ${script_dir}/nsio_test_0${script_num}.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/namespace_io/nsio_test_0${script_num}
    echo "Namespace+I/O test 0${script_num} end..."
    echo -e "\n"
done

for ((script_num=10; script_num<=24; script_num++)) ;do
    echo "Namespace+I/O test ${script_num} start..."
    unbuffer ${script_dir}/nsio_test_${script_num}.sh $dev_name $test_count | ${script_dir}/write_log.sh ${script_dir}/../../../log/namespace_io/nsio_test_${script_num}
    echo "Namespace+I/O test ${script_num} end..."
    echo -e "\n"
done
