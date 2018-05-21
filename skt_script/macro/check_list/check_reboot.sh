#! /bin/bash

name=`ps -aux | grep "$1 $2" | head -n 1 | cut -d':' -f3 | cut -d' ' -f2`
	sleep 5

name=`ps -aux | grep "$1 $2" | head -n 1 | cut -d':' -f3 | cut -d' ' -f2`

if [ $name = $1 ]
then
	echo "NVMe device detected fail (device check 1)"
    exit 1
else
    echo "NVMe device detected success (device check 1)"
	exit 0
fi


