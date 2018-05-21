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

#Firmware
if [ ${bn:1:1} -eq 0 ] 
then
	echo "Firmware bit off"
    rm oacs_log.txt
    exit 1
else
	echo "Firmware bit on"
    rm oacs_log.txt
    exit 0
fi
