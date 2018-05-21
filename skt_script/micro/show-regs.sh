#!/bin/bash

nvme show-regs /dev/nvme0

ret=`echo $?`
if [ $ret -eq 0 ]; then
    echo "show-regs command pass"
    exit 0
else
    echo "show-regs command fail"
    exit 1
fi
