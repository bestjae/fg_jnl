#!/bin/bash
argc=$#
dev_name=$1

if [ $argc -lt 1 ]; then
    echo "Usage : ./get_support_ns [dev_name]"
    exit 1
fi

nvme id-ctrl $dev_name | grep nn > support_ns.txt

while read line; do
	temp=`echo $line | cut -d':' -f2`
	temp=`echo $temp | cut -d'x' -f2`
done < support_ns.txt

rm support_ns.txt

exit $temp
