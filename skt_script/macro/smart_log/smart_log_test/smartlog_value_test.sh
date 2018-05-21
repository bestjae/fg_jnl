#!/bin/bash

argc=$#
dev_name=$1
nid=$2

if [ $argc -lt 2 ]; then
    echo "Usage : ./smartlog_value_test [device] [namespace id]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

nvme smart-log $dev_name --namespace-id=$nid > smart_log.txt
nvme smart-log /dev/nvme0 > smart_log.txt

#temperature
tmin=0
tmax=100
#temperature sensor
tsmin=0
tsmax=100

i=0

echo "check smart-log value"
while read line; do
	if [ $i -eq 0 ]
	then
		name[$i]=`echo $line | cut -d':' -f1`
		temp=`echo $line | cut -d':' -f2`
		var[$i]=`echo $temp | cut -d' ' -f1`

		i=`expr $i + 1`
		
		name[$i]=`echo $temp | cut -d' ' -f2`
		var[$i]=`echo $line | cut -d':' -f3`
	else
		name[$i]=`echo $line | cut -d':' -f1`
		var[$i]=`echo $line | cut -d':' -f2`
	fi

	i=`expr $i + 1`
done < smart_log.txt

i=`expr $i - 1`

while [ $i -ne 1 ]; do
	var[$i]=`echo ${var[$i]} | sed 's/[^0-9]//g'`
	i=`expr $i - 1`
done

j=2
if [ ! -e old_log.txt ]
then
	for (( index = 2; index <= 18; index++ )); do
		oldvar[$index]=0
		echo "${var[$index]}" >> old_log.txt
	done
else
	while read oldline; do
		oldvar[$j]=$oldline
		j=`expr $j + 1`
	done < old_log.txt

	rm old_log.txt
	
	for (( index = 2; index <= 18; index++ )); do
		echo "${var[$index]}" >> old_log.txt
	done
fi

for (( index = 2; index < ${#var[@]}; index++ )); do
	if [ $index -eq 2 ]
	then
		if [ ${oldvar[$index]} -gt ${var[$index]} ]
		then
			echo "${name[$index]} (${oldvar[$index]} / ${var[$index]} : fail)"
		else
			echo "${name[$index]} (${oldvar[$index]} / ${var[$index]} : success)"
		fi
	fi

	if [ $index -eq 3 ]
	then
		if [ $tmin -le ${var[$index]} -a $tmax -ge ${var[$index]} ]
		then
			echo "${name[$index]} (${var[$index]} : correct)"
		else
			echo "${name[$index]} (${var[$index]} : incorrect)"
		fi
	fi

	if [ $index -ge 4 -a $index -le 5 ]
	then
		if [ ${oldvar[$index]} -lt ${var[$index]} ]
		then
			echo "${name[$index]} (${oldvar[$index]} / ${var[$index]} : fail)"
		else
			echo "${name[$index]} (${oldvar[$index]} / ${var[$index]} : success)"
	    fi	

	fi

	if [ $index -ge 6 -a $index -le 18 ]
	then
		if [ ${oldvar[$index]} -gt ${var[$index]} ]
		then
			echo "${name[$index]} (${oldvar[$index]} / ${var[$index]} : fail)"
		else
			echo "${name[$index]} (${oldvar[$index]} / ${var[$index]} : success)"
		fi
	fi

	if [ $index -ge 19 ]
	then
		if [ $tsmin -le ${var[$index]} -a $tsmax -ge ${var[$index]} ]
		then
			echo "${name[$index]} (${var[$index]} : correct)"
		else
			echo "${name[$index]} (${var[$index]} : incorrect)"
		fi	
	fi
done

rm smart_log.txt
