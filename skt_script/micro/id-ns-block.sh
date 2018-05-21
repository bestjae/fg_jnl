#!/bin/bash
#$1 = namespace id

nvme id-ns /dev/nvme0n1 
nvme id-ns /dev/nvme0n1  --vendor-specific
nvme id-ns /dev/nvme0n1  --raw-binary
nvme id-ns /dev/nvme0n1  --human-readable

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "id-ns command pass"
else
    echo "id-ns command fail"
fi
