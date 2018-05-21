#!/bin/bash

nvme id-ctrl /dev/nvme0 --human-readable 
nvme id-ctrl /dev/nvme0 --raw-binary 
nvme id-ctrl /dev/nvme0 --vendor-specific

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "id-ctrl command pass"
else
    echo "id=ctrl command fail"
fi
