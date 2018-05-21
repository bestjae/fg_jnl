# SPOR Time Measuring Automation Tool 
# Authored by Yongseok Oh
# 2016/01/21
#!/bin/bash -x

DEV_NAME=/dev/nvme0n1
LOG_NAME=spor_time_log.txt

for((i=0;i<10;i++))
do
    echo "Fio ... "
    fio --bs=4k --ioengine=libaio --iodepth=32 --direct=1 --runtime=120 --numjobs=4 --thread --group_reporting --filename=${DEV_NAME} --name=rand-write --rw=randwrite

    echo "Power Off ..."
	python power_off.py

	sleep 20

    echo "Power On ..."
	python power_on.py

    basetime=$(date +%s%N)

    echo "Rescanning ${DEV_NAME} ..."
    while [ ! -e $DEV_NAME ]
    do
        echo 1 > /sys/bus/pci/rescan
        sleep 0.5
    done

    spor_time=$(echo "scale=3;($(date +%s%N) - ${basetime})/(1*10^09)" | bc)

    echo $i SPOR Time : $spor_time seconds "[ " $(date) " ]" 
    echo $i SPOR Time : $spor_time seconds "[ " $(date) " ]" >> $LOG_NAME
done 


#if [ -e $DEV_NAME ]; then
#	dd if=/dev/sdb of=/dev/null bs=4K count=1 iflag=direct
#	dd if=/dev/zero of=$DEV_NAME bs=4K count=1024 oflag=direct
#	hdparm -F $DEV_NAME
#fi
