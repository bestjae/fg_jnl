# !/bin/bash

str=`nvme list /dev/nvme0`
str_err="No NVMe devices detected."

echo "--------nvme list test---------"
if [ "$str" = "$str_err" ] 
then
    echo "nvme device detected fail"
    exit 1
else
    echo "nvme device detected success"
fi

echo "-------------------------------"

