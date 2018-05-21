#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
firmware_path=$2
test_count=$3

controller_id=1
cur_firmware_slot=6
start_slot=2
end_slot=7
target_slot=$start_slot

${script_dir}/../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 2 ]; then
    echo "Usage : ./action2.sh [dev_name] [firmware_path]"
    ${script_dir}/../../micro/input_error_exit.sh
fi

echo "<Test Environment Check>"
${script_dir}/../../macro/check_list/ls_dev.sh $dev_name
ret=`echo $?`
if [ $ret -eq 1 ];
then 
    echo "Enviroment check fail"
    echo "Test End"
    exit 1
fi

${script_dir}/oacs_firmware.sh $dev_name
ret=`echo $?`
if [ $ret -eq 1 ];
then 
    echo "Enviroment check fail"
    echo "Test End"
    exit 1
fi
echo -e "\n"

echo "<Test Environment initilazation>"
global_ns=`cat ${script_dir}/../../micro/ns`
if [ $global_ns -eq 0 ]; then
    echo "No namespace for delete"
else
    echo "Deleting all namespace for test\n"
    for (( i=1;i<=$total_support_ns;i++ ))
    do
	    ${script_dir}/../../micro/delete_ns1.sh $dev_name ${i}  > /dev/null 2> /dev/null
    done
fi   

for (( i=1;i<=$total_support_ns;i++ ))
do
    ${script_dir}/../../micro/create_ns1.sh $dev_name 40960000   > /dev/null 2> /dev/null
    ${script_dir}/../../micro/attach_ns1.sh $dev_name $i $controller_id   > /dev/null 2> /dev/null
done

echo "Firmware initialization"
${script_dir}/../../micro/fw-download.sh $dev_name $firmware_path/firmware.tar 
${script_dir}/../../micro/fw-activate.sh $dev_name 1 $start_slot

${script_dir}/../check_list/power_cycle.sh
echo -e "\n"

echo "<Test scenario : update firmware with action 2>"
${script_dir}/fw_version_editor/fw_version_editor.sh $firmware_path

for (( test=1;test<=test_count;test++ ))
do
    for (( i=1;i<=$cur_firmware_slot;i++ ))
    do
        echo "Target slot:" $target_slot ", Taget firmware version: testfw0"$target_slot
        for (( slot=$start_slot;slot<=$end_slot;slot++ ))
        do
            ${script_dir}/../../micro/fw-download.sh $dev_name firmware_$slot.tar
            if [ $slot -eq $target_slot ]; then
                ${script_dir}/../../micro/fw-activate.sh $dev_name 0 $slot
                ${script_dir}/../../micro/fw-activate.sh $dev_name 2 $slot
            else
                ${script_dir}/../../micro/fw-activate.sh $dev_name 0 $slot
            fi
        done
        
		${script_dir}/../check_list/power_cycle.sh
        
        ${script_dir}/../../micro/fw-check.sh $dev_name ./firmware_$target_slot.tar 
        echo -e "\n"
    
        target_slot=`expr $target_slot + 1`
    done
    target_slot=$start_slot
done

${script_dir}/../../micro/rm_remain_file.sh ${script_dir}
echo "<Device fault verify>"
${script_dir}/../check_list/power_cycle.sh
${script_dir}/../check_list/fail_test.sh $dev_name $0

