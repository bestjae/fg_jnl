#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

argc=$#
dev_name=$1
controller_id=1
size=(12000 26000 56000 1000000 160000 2450000 10000000 12300000)
size_16=(0x2ee0 0x6590 0xdac0 0xf4240 0x27100 0x256250 0x989680 0xbbaee0)
test_count=$2

${script_dir}/../../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 2 ]; then
    echo "Usage : ./ns_test_24.sh [device] [test_count]"
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
function del_all() {
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
echo -e "\n"
}
del_all
for (( j=1;j<=$total_support_ns;j++ ))
do
    ${script_dir}/../../../micro/create_ns1.sh $dev_name ${size[$((j-1))]}   
    ${script_dir}/../../../micro/attach_ns1.sh $dev_name $j $controller_id 
done


${script_dir}/../../check_list/power_cycle.sh
echo -e "\n"

echo "<Test scenario : Various size namespace create -> namespace nsze check>"
for (( k=1; k<=$test_count;k++ ))
do
    echo "Test scenario progress :" $k"/"$test_count 
    for (( l=1;l<=$total_support_ns;l++ ))
    do
    	nsze=`nvme id-ns $dev_name -n $l | grep nsze | awk '{print $3}'`
    	
    	if [ $nsze = ${size_16[$((l-1))]} ];
    	then
    		echo "namespace $l nsze correct ($nsze = ${size_16[$((l-1))]})"
    	else
    		echo "namespace $l nsze uncorrect ($nsze = ${size_16[$((l-1))]})"
			echo "test fail"
    		exit 1
    	fi	
    done
	echo -e "\n"
done

${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh $dev_name $0

