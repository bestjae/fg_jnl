#! /bin/bash 

diff1=$1
diff2=$2

argc=$#

script_dir=$(cd "$(dirname "$0")" && pwd)

if [ $argc -lt 2 ]; then
	echo "Usage : ./check_diff.sh [diff1] [diff2]"
	exit 1
fi

result=`diff ${diff1} ${diff2}`

if [ "${result}" ] ;
then
	echo "I/O verify fail"
	exit 1
else
	echo "I/O verify success"
	exit 0
fi
