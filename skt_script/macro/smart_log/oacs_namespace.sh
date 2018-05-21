#!/bin/bash
argc=$#
dev_name=$1

if [ $argc -lt 1 ]; then
    echo "Usage : ./oacs_firmware [dev_name]"
    ${script_dir}/../../micro/input_error_exit.sh
fi

nvme id-ctrl $dev_name | grep oacs > oacs_log.txt

while read line; do
	temp=`echo $line | cut -d':' -f2`
	temp=`echo $temp | cut -d'x' -f2`
done < oacs_log.txt

temp=`echo $temp | tr '[a-z]' '[A-Z]'`
bn=`echo "obase=2; ibase=16; $temp" | bc`

#Namespace
if [ ${bn:0:1} -eq 0 ] 
then
	echo "Namespace management bit off"
    exit 1
else
	echo "Namespace management bit on"
fi

rm oacs_log.txt
