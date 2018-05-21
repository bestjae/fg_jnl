# SPOR Time Measuring Automation Tool 
# Authored by Yongseok Oh
# 2016/01/21
#!/bin/bash 

DEV_NAME=/dev/nvme0

basetime=$(date +%s%N)
rescan_test_count=0
total_support_ns=8

for (( i=1;i<=$total_support_ns;i++ ))
do
	echo $DEV_NAME " rescan start"
	DEV_NAME=/dev/nvme0n${i}
	while [ ! -e $DEV_NAME ]
	do
	    echo 1 > /sys/bus/pci/rescan
	    sleep 1
	    rescan_test_count=`expr $rescan_test_count + 1`
	    if [ $rescan_test_count -eq 20 ]; then
	        echo -e "\n"
	        echo $DEV_NAME "Rescan retry fail"
			echo "Press CTRL + c for stop"
		
			for((;;))
			do
				echo 1 > /dev/null
				sleep 1
			done
	    fi
	done
	echo $DEV_NAME "Rescan retry success"
done
printf "\n"

#spor_time=$(echo "scale=3;($(date +%s%N) - ${basetime})/(1*10^09)" | bc)

#echo $i SPOR Time : $spor_time seconds "[ " $(date) " ]" 
