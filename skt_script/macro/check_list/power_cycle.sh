#! /bin/bash 

script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
option=$1

if [ $argc -lt 1 ]; then
	option=`cat ${script_dir}/power_option`
fi

if [ $option -eq 1 ] ; then	
	rmmod nvme 

	python ${script_dir}/../../quarch/power_off.py
	sleep 1

	python ${script_dir}/../../quarch/power_on.py
	sleep 2

	modprobe nvme

	source ${script_dir}/../../quarch/rescan_retry.sh
	nvme set-feature /dev/nvme0 -f 0xb -v 0 > /dev/null 2> /dev/null
	exit 0
elif [ $option -eq 2 ] ; then
	python ${script_dir}/../../quarch/power_off.py
	python ${script_dir}/../../quarch/power_on.py	

	sleep 2

	source ${script_dir}/../../quarch/rescan_retry.sh
	nvme set-feature /dev/nvme0 -f 0xb -v 0 > /dev/null 2> /dev/null
	exit 0
elif [ $option -eq 3 ] ; then
	rmmod nvme
	modprobe nvme
	nvme set-feature /dev/nvme0 -f 0xb -v 0 > /dev/null 2> /dev/null
	exit 0
elif [ $option -eq 4 ] ; then
	nvme set-feature /dev/nvme0 -f 0xb -v 0 > /dev/null 2> /dev/null
	exit 0
else
	echo "Usage : ./power_cycle.sh [option_num]"
	echo "	1. npor 2. spor 3. only module 4. no power cycle"
fi


