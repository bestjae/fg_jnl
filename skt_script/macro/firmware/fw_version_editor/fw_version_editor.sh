#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
firmware_path=$1
cur_firmware_slot=6
start_slot=2
end_slot=7

if [ $argc -lt 1 ]; then
    echo "Usage : ./fw_version_editor.sh [fw_directory]"
    exit 1
fi

cp ${firmware_path}/firmware.tar ./
tar -xvf firmware.tar > /dev/null 2> /dev/null

for (( i=$start_slot;i<=$end_slot;i++ ))
do
    ${script_dir}/../fwImageHeader/fwImageHeader 1 > /dev/null 2> /dev/null
    echo "testfw0$i" >> fwHeader.bin
    ${script_dir}/../fwImageHeader/fwImageHeader 2 > /dev/null 2> /dev/null
	#hexdump -C fwHeader.bin
    tar -cvf firmware.tar fwHeader.bin NvmeOpRom8607.romp NODE*.bin fccFlat.bin  > /dev/null 2> /dev/null
    ${script_dir}/../fwImageHeader/fwImageHeader 0 > /dev/null 2> /dev/null
    ${script_dir}/../crc16-ONFI/crc16-ONFI -b firmware.tar >> firmware.tar 
    mv firmware.tar firmware_$i.tar
done

rm *.bin *.romp
