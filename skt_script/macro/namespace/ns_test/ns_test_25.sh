#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

argc=$#
dev_name=$1
controller_id=1
test_count=$2

${script_dir}/../../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 2 ]; then
    echo "Usage : ./ns_test_25.sh [device] [test_count]"
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

${script_dir}/../oacs_format.sh $dev_name
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
function del_all(){
global_ns=`cat ${script_dir}/../../../micro/ns`
if [ $global_ns -eq 0 ]; then
    echo "there is no namespace for delete"
else
    nvme list-ns $dev_name > ${script_dir}/../../check_list/list-ns.txt
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
echo -e "\n"
}

del_all

tnvmcap=`nvme id-ctrl $dev_name | grep tnvmcap | awk '{print $3}'`
echo "<Test scenario : Impossible namespace size create>"

for (( j=1;j<=$test_count;j++ ))
do
    echo "Test scenario progress :" $j"/"$test_count 
	echo "current tnvmcap : $tnvmcap"
	echo "capacity per namespace : $(($tnvmcap / 8))"

	tlba=`expr $tnvmcap \/ 512`
	for (( k=1;k<=$total_support_ns;k++ ))
	do	
		${script_dir}/../../../micro/create_ns1.sh $dev_name $((tlba / 8)) 
		${script_dir}/../../../micro/attach_ns1.sh $dev_name $k $controller_id  
    	
	done
	tnvmcap=`expr $tnvmcap \* 2`
	del_all	
done
${script_dir}/../../../micro/create_ns1.sh $dev_name 409600000 > /dev/null 2> /dev/null
${script_dir}/../../../micro/attach_ns1.sh $dev_name 1 $controller_id  > /dev/null 2> /dev/null


${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh $dev_name $0
