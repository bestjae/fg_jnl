#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
controller_id=1
total_support_ns=8
test_count=$2
request_size=512

tnvmcap=`nvme id-ctrl $dev_name | grep tnvmcap | awk '{print $3}'`
tlba=`expr $tnvmcap \/ 512`

if [ $argc -lt 2 ]; then
    echo "Usage : ./nsio_test_23.sh [device name] [test_count]"
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
    for (( i=i;i<=$total_support_ns;i++ ))
    do
	    ${script_dir}/../../../micro/delete_ns1.sh $dev_name $i 
        
    done
fi   
echo -e "\n"
   

for (( i=1;i<=$total_support_ns;i++ ))
do
    ${script_dir}/../../../micro/create_ns1.sh $dev_name $((tlba/8 - 100)) 
    ${script_dir}/../../../micro/attach_ns1.sh $dev_name $i $controller_id 
done



${script_dir}/../../check_list/power_cycle.sh
			

echo "<Test scenario : namespace out of range write verify test>"
for (( j=1;j<=$test_count;j++ ))
do
    echo "Test scenario progress :" $j"/"$test_count 
    for (( k=1;k<=$total_support_ns;k++ ))
    do
    	for (( l=1;l<2;l++ ))
    	do 
	    	${script_dir}/../../../micro/write.sh ${dev_name}n${k} $((tlba/8 -100 + l)) $request_size 
			if [ $? -eq 0  ] ; then
				echo "${dev_name}n${k} out of range write commad success  -> test fail"
				exit 1
        	else
				
			fi
	    	echo "write ${dev_name}n${k} (start block : $l, request_size :${request_size} sector)"  
	    	${script_dir}/../../../micro/write.sh ${dev_name}n${k} $((tlba/8 -500 + l)) $request_size 
			if [ $? -eq 0  ] ; then
				echo "${dev_name}n${k} write from inside range to out of range  success  -> test fail"
				exit 1
        	fi
	    	echo "write ${dev_name}n${k} (start block : $l, request_size :${request_size} sector)"  
		done
		echo "${dev_name}n${k} out of range write commad fail  -> test success"
	    echo -e "\n"
    done
	echo -e "\n"
done


${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh ${dev_name} $0
