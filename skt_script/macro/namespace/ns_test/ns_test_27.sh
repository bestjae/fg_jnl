#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

argc=$#
dev_name=$1
ns_size=40960000
overwrite_gap=1000
controller_id=1
test_count=$2

${script_dir}/../../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`


if [ $argc -lt 2 ]; then
    echo "Usage : ./ns_test_27.sh [device] [test_count]"
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

echo "<Test scenario : Namespce LBA overwrite -> I/O -> power cycle -> device check>"
for (( i=1;i<=$test_count;i++ ))
do
    echo "Test scenario progress :" $i"/"$test_count 
# I/O verify 

    nvme list-ns $dev_name  > ${script_dir}/list-ns.txt
    nvme_list=`${script_dir}/../../check_list/list-ns-parsing.sh`
    array=( ${nvme_list} )
    total_ns=${#array[*]}
    for ((j=1;$j<=test_count;j++))
    do
    	for ((l=1;$l<total_ns;l++))
    	do
    		ns_size_i=`expr $ns_size \* $l`
    		start_block=`expr $ns_size_i - $overwrite_gap`
    		req_size=`expr $overwrite_gap \* 2`

			echo "write ${dev_name}n${array[$((l-1))]} start_block=$start_block request_size=$req_size "
			${script_dir}/../../../micro/write.sh ${dev_name}n${array[$((l-1))]} $start_block $req_size > /dev/null 2> /dev/null
			ret=`echo $?`	
			if [ $ret -eq 1 ] ; then
				echo " write command not complete : purpose of testing            "
			fi
			echo "read ${dev_name}n${array[$((l-1))]} start_block=$start_block request_size=$req_size "
			${script_dir}/../../../micro/read.sh ${dev_name}n${array[$((l-1))]} $start_block $req_size  > /dev/null 2> /dev/null
			ret=`echo $?`	
			if [ $ret -eq 1 ] ; then
				echo " read command not complete : purpose of testing            "
			fi
		done
	done

	echo -e "\n"
done

${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh $dev_name $0

