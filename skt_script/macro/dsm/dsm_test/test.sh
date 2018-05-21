#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
controller_id=1
test_count=$2
request_size=16

${script_dir}/../../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

if [ $argc -lt 2 ]; then
    echo "Usage : ./dsm_test_01.sh [device name] [test_count]"
    exit 1
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

${script_dir}/../oncs_dsm_check.sh $dev_name
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
    printf "Deleting all namespace for test"
    for (( i=1;i<=$total_support_ns;i++ ))
    do
	    ${script_dir}/../../../micro/delete_ns1.sh $dev_name ${i} > /dev/null 2> /dev/null
        printf "."
    done
fi   
echo -e "\n"
   

for (( i=1;i<=$total_support_ns;i++ ))
do
    ${script_dir}/../../../micro/create_ns1.sh $dev_name 40960000 > /dev/null 2> /dev/null
    ${script_dir}/../../../micro/attach_ns1.sh $dev_name $i $controller_id > /dev/null 2> /dev/null
done



${script_dir}/../../check_list/power_cycle.sh

echo "<Test scenario : namespace write -> dsm -> read -> I/O verify test>"
for (( j=1;j<=$test_count;j++ ))
do
    echo "Test scenario progress :" $j"/"$test_count 
    for (( k=1;k<=$total_support_ns;k++ ))
    do
    	for (( l=1;l<50;l++ ))
    	do
	    	${script_dir}/../../../micro/write.sh ${dev_name}n${k} 16 ${request_size} 
	    	echo "write ${dev_name}n${k} (start block : 0, request_size :${request_size} sector)"  
			${script_dir}/../../../micro/dsm.sh ${dev_name}n${k} -d 16 ${request_size} 
	    	echo "DSM ${dev_name}n${k} (start block : 0, request_size :${request_size} sector)"  
	    	${script_dir}/../../../micro/read.sh ${dev_name}n${k} 16 ${request_size} 
	    	echo "read ${dev_name}n${k} (start block : 0, request_size :${request_size} sector)"  
	    	${script_dir}/../../check_list/check_diff.sh ${script_dir}/write_data.dat ${script_dir}/read_data.dat > /dev/null 2> /dev/null
			if [ $? -eq 0  ] ; then
	        	echo "$1 DSM test fail"
                echo -e "\n"
	    		exit 1
        	fi
			
	    	${script_dir}/../../check_list/check_diff.sh ${script_dir}/write_zero.dat ${script_dir}/read_data.dat > /dev/null 2> /dev/null
			if [ $? -eq 1  ] ; then
	        	echo "$1 DSM test fail"
                echo -e "\n"
	    		exit 1
        	fi
            echo -e "\n"
		done
		echo "${dev_name}n${k} dsm verify success"
    done
	echo -e "\n"
done


${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh ${dev_name} $0
