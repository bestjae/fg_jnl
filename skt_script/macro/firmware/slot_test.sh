#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
firmware_path=$2
test_count=$3

controller_id=1
disable_slot=1
start_slot=2
end_slot=7

${script_dir}/../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 2 ]; then
    echo "Usage : ./slot_test.sh [dev_name] [firmware_path]"
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


echo "<Test scenario : using disable slot 1>"
for (( i=1;i<=$test_count;i++ ))
do
    echo "Test scenario progress :" $i"/"$test_count 
    for (( l=1;l<=10;l++ ))
        do
        ${script_dir}/../../micro/fw-download.sh $dev_name $firmware_path/firmware.tar
        ${script_dir}/../../micro/fw-activate.sh $dev_name 1 1 > /dev/null 2> /dev/null
        ret=`echo $?`
        if [ $ret -eq 6 ]; then
            echo "fw-activate command not complete -> purpose of testing"
        else    
            echo "fw-activate : fail"
        fi
    done
    printf "\n"
done

echo "<Test scenario : using disable slot (over slot number range)>"
for (( i=1;i<=$test_count;i++ ))
do
    echo "Test scenario progress :" $i"/"$test_count 
    for (( l=1;l<=10;l++ ))
    do
        end_slot=`expr $end_slot + $i`
        ${script_dir}/../../micro/fw-download.sh $dev_name $firmware_path/firmware.tar
        ${script_dir}/../../micro/fw-activate.sh $dev_name 1 $end_slot > /dev/null 2> /dev/null
        ret=`echo $?`
        if [ $ret -eq 22 ]; then
            echo "fw-activate command not complete -> purpose of testing"
        else    
            echo "fw-activate : fail"
        fi
    done
    printf "\n"
done

${script_dir}/../../micro/rm_remain_file.sh ${script_dir}
echo "<Device fault verify>"
${script_dir}/../check_list/power_cycle.sh
${script_dir}/../check_list/fail_test.sh $dev_name $0
