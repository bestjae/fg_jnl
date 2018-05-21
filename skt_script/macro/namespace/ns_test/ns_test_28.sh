#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

argc=$#
dev_name=$1
controller_id=1
test_count=$2
num_attach=2

${script_dir}/../../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 2 ]; then
    echo "Usage : ./ns_test_28.sh [device] [test_count]"
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
echo -e "\n"


echo "<Test scenario : Namespace create -> attach -> list-ns based active/inactive namespace check>"
for (( i=1;i<=$test_count;i++ ))
do
    num_attach=2
    echo "Test scenario progress :" $i"/"$test_count 
    for (( set=1;set<=4;set++ ))
    do
        for (( j=1;j<=$total_support_ns;j++ ))
        do
            ${script_dir}/../../../micro/create_ns1.sh $dev_name 40960000 
        done
        
        for (( k=1;k<=$num_attach;k++ ))
        do
            ${script_dir}/../../../micro/attach_ns1.sh $dev_name $k $controller_id
        done
    
        echo "(create" `expr $j - 1` "namesapce -> attach" `expr $k - 1` "namesapce)"

        nvme list-ns $dev_name --all > ${script_dir}/../../check_list/list-ns.txt
        nvme_list=`${script_dir}/../../check_list/list-ns-parsing.sh`
        ns_array=( ${nvme_list} )

        printf "checking acive/inactive namesapce :"
        for (( l=1;l<=$num_attach;l++ ))
        do
            idx=`expr $l - 1`
            #echo "$idx"
            #echo "ns_array[$idx] = ${ns_array[$idx]}, l = $l"
            if [ ${ns_array[$idx]} -ne $l ]; then
                printf "Test fail\n"
                exit 1
            fi
        done
        printf "Test success\n"
    
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
           
            printf "Initialization : Deleting all namespace for test\n"
            for ((del=0;del<$total_ns;del++))
            do
        	    ${script_dir}/../../../micro/delete_ns1.sh $dev_name ${array[$i]} 
            done
        fi   
            
        num_attach=`expr $num_attach + 2`
    done
    echo -e "\n"
done
echo -e "\n"

${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh $dev_name $0

