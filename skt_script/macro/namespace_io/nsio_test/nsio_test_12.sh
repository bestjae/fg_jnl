#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
controller_id=1
test_count=$2
${script_dir}/../../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 2 ]; then
    echo "Usage : ./nsio_test_12.sh [device name] [test_count]"
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

${script_dir}/../oacs_format.sh $dev_name
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
    for (( i=1;i<=$total_support_ns;i++ ))
    do
	    ${script_dir}/../../../micro/delete_ns1.sh $dev_name ${i} 
        
    done
fi   
echo -e "\n"
   

for (( i=1;i<=$total_support_ns;i++ ))
do
    ${script_dir}/../../../micro/create_ns1.sh $dev_name 40960000 
    ${script_dir}/../../../micro/attach_ns1.sh $dev_name $i $controller_id 
done



${script_dir}/../../check_list/power_cycle.sh

echo "<Test scenario : (/dev/nvme0 : reset),(/dev/nvme0n1~nvme0n8 : flush)"
for (( i=1;i<=$test_count;i++ ))
do
    echo "Test scenario progress :" $i"/"$test_count 
    printf "/dev/nvme0n1 -> "
    ${script_dir}/../../../micro/flush.sh $dev_name 1 
    printf "/dev/nvme0n2 -> "
    ${script_dir}/../../../micro/flush.sh $dev_name 2 
    printf "/dev/nvme0n3 -> "
    ${script_dir}/../../../micro/flush.sh $dev_name 3 
    printf "/dev/nvme0n4 -> "
    ${script_dir}/../../../micro/flush.sh $dev_name 4 
    printf "/dev/nvme0n5 -> "
    ${script_dir}/../../../micro/flush.sh $dev_name 5 
    printf "/dev/nvme0n6 -> "
    ${script_dir}/../../../micro/flush.sh $dev_name 6 
    printf "/dev/nvme0n7 -> "
    ${script_dir}/../../../micro/flush.sh $dev_name 7 
    printf "/dev/nvme0n8 -> "
    ${script_dir}/../../../micro/flush.sh $dev_name 8 
done
echo -e "\n"

      
${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh ${dev_name} $0
