#!/bin/bash

dev_name=$1
argc=$#

if [ $argc -lt 1 ]; then
    echo "Usage : ./oncs_dsm_check [dev_name]"
    ${script_dir}/../../micro/input_error_exit.sh
fi

nvme id-ctrl $dev_name | grep oncs > oncs_log.txt

while read line; do
	temp=`echo $line | cut -d':' -f2`
	temp=`echo $temp | cut -d'x' -f2`
done < oncs_log.txt

temp=`echo $temp | tr '[a-z]' '[A-Z]'`
bn=`echo "obase=2; ibase=16; $temp" | bc`

#DSM
if [ ${bn:3:1} -eq 0 ] 
then
    exit 1
else
    exit 0
fi

rm oncs_log.txt
