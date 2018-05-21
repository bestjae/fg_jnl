#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

argc=$#
dev_name=$1
controller_id=1
test_count=$2

${script_dir}/../../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 1 ]; then
    echo "Usage : ./smart_spor_test.sh [device]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

echo "<Test Environment Check>"
${script_dir}/../../../macro/check_list/ls_dev.sh $dev_name
ret=`echo $?`
if [ $ret -eq 1 ];
then 
    echo "Enviroment check fail"
    echo "Test End"
    exit 1
fi

${script_dir}/../oacs_namespace.sh $dev_name
ret=`echo $?`
if [ $ret -eq 1 ];
then 
    echo "Enviroment check fail"
    echo "Test End"
    exit 1
fi
echo -e "\n"

echo "<Test Environment initilazation>"
global_ns=`cat ${script_dir}/../../../micro/ns`
if [ $global_ns -eq 0 ]; then
    echo "No namespace for delete"
else
    printf "Deleting all namespace for test\n"
    for (( i=0;i<$total_support_ns;i++ ))
    do
	    ${script_dir}/../../../micro/delete_ns1.sh $dev_name ${array[$i]} > /dev/null 2> /dev/null
        
    done
fi   
echo -e "\n"
   

for (( i=1;i<=$total_support_ns;i++ ))
do
    ${script_dir}/../../../micro/create_ns1.sh $dev_name 40960000 > /dev/null 2> /dev/null
    ${script_dir}/../../../micro/attach_ns1.sh $dev_name $i $controller_id > /dev/null 2> /dev/null
done



${script_dir}/../../check_list/power_cycle.sh

echo "<Test scenario : smart-log value test with SPOR>"
for(( i=1;i<=$test_count;i++ ))
do
    echo "Test scenario progress :" $i"/"$test_count 
    for (( j=1;j<=$total_support_ns;j++ ))
    do
        echo "Namespace = $j smart log check with I/O"
        ${script_dir}/smartlog_value_test.sh $dev_name $j 
        echo -e "\n"
    done
    echo "Global Namespace smart log check with I/O"
    ${script_dir}/smartlog_value_test.sh $dev_name -1
    
    echo -e "\n"
    
#   python ${script_dir}/../../../quarch/power_off.py
#   python ${script_dir}/../../../quarch/power_on.py
#   ${script_dir}/../../quarch/rescan_retry.sh > /dev/null 2> /dev/null
    
    ${script_dir}/../../check_list/power_cycle.sh
done
echo -e "\n"

${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}
echo "<Device fault verify>"


${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh $dev_name $0
