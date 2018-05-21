#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

argc=$#
dev_name=$1
controller_id=1
test_count=$2
ns_size=40960000

${script_dir}/../../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 2 ]; then
    echo "Usage : ./ns_test_29.sh [device] [test_count]"
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
    nvme list-ns $dev_name  > ${script_dir}/../../check_list/list-ns.txt
    nvme_list=`${script_dir}/../../check_list/list-ns-parsing.sh`
    array=( ${nvme_list} )
    list_num=${#nvme_list}
    temp=`expr $list_num + 1`
    total_ns=${#array[*]}
   
    printf "Deleting all namespace for test\n"
    for ((i=0;$i<total_ns;i++))
    do
	    ${script_dir}/../../../micro/delete_ns1.sh $dev_name ${array[$i]} 
        
    done
fi   

for (( i=1;i<=$total_support_ns;i++ ))
do
    ${script_dir}/../../../micro/create_ns1.sh $dev_name $ns_size 
    ${script_dir}/../../../micro/attach_ns1.sh $dev_name $i $controller_id 
done
echo -e "\n"

echo "<Test scenario : Namespace create -> list-ns -> controller reset -> power cycle -> list-ns -> namespace verify>"
for (( i=1;i<=$test_count;i++ ))
do
    echo "Test scenario progress :" $i"/"$test_count 
    ${script_dir}/../../../micro/list-ns.sh $dev_name > before.txt
    ${script_dir}/../../../micro/list-ns.sh $dev_name --all > before_all.txt
   
    
    
    ${script_dir}/../../check_list/power_cycle.sh
    ${script_dir}/../../../micro/reset.sh $dev_name 
   
    ${script_dir}/../../../micro/list-ns.sh $dev_name > after.txt
    ${script_dir}/../../../micro/list-ns.sh $dev_name --all > after_all.txt

    diff before.txt after.txt
    ret=$?

    if [ $ret -eq 0 ]; then
        echo "list-ns verify pass"
        rm before.txt after.txt
    else
        echo "list-ns verify test fail"
        exit 1
    fi

    
    diff before_all.txt after_all.txt
    ret=$?

    if [ $ret -eq 0 ]; then
        echo "list-ns with --all option verify pass"
        rm before_all.txt after_all.txt
    else
        echo "list-ns with --all option verify fail"
        exit 1
    fi
    echo -e "\n"
done
echo -e "\n"

${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh $dev_name $0

