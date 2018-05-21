# SPOR Time Measuring Automation Tool 
# Authored by Yongseok Oh
# 2016/01/21
#!/bin/bash 

DEV_NAME_0=/dev/nvme0n1
DEV_NAME_1=/dev/nvme1n1

basetime=$(date +%s%N)
rescan_test_count=0
total_support_ns=8

while [ ! -e $DEV_NAME_0 ]
do
    echo 1 > /sys/bus/pci/rescan
    sleep 1
    rescan_test_count=`expr $rescan_test_count + 1`
    if [ $rescan_test_count -eq 20 ]; then
        echo -e "\n"
        echo $DEV_NAME_0 " Rescan retry fail"
		echo "Press CTRL + c for stop"
	
		for((;;))
		do
			echo 1 > /dev/null
			sleep 1
		done
    fi
done

echo $DEV_NAME_0 " Rescan retry success"

while [ ! -e $DEV_NAME_1 ]
do
    echo 1 > /sys/bus/pci/rescan
    sleep 1
    rescan_test_count=`expr $rescan_test_count + 1`
    if [ $rescan_test_count -eq 20 ]; then
        echo -e "\n"
        echo $DEV_NAME_1 "Rescan retry fail"
		echo "Press CTRL + c for stop"
	
		for((;;))
		do
			echo 1 > /dev/null
			sleep 1
		done
    fi
done

echo $DEV_NAME_1 " Rescan retry success"

#spor_time=$(echo "scale=3;($(date +%s%N) - ${basetime})/(1*10^09)" | bc)

#echo $i SPOR Time : $spor_time seconds "[ " $(date) " ]" 
