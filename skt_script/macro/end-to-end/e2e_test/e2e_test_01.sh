#! /bin/bash 

script_dir=$(cd "$(dirname "$0")" && pwd)
argc=$#
dev_name=$1
controller_id=1
total_support_ns=8
test_count=$2
request_size=1


if [ $argc -lt 1 ]; then
	echo "Usage : ./ete_test_01.sh [device name]"
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

echo -e "\n"

echo "<Test Environment initilazation>"
global_ns=`cat ${script_dir}/../../../micro/ns`
if [ $global_ns -eq 0 ]; then
    echo "No namespace for delete"
else
    printf "Deleting all namespace for test\n"
    for (( i=1;i<=$total_support_ns;i++ ))
    do
	    ${script_dir}/../../../micro/delete_ns1.sh $dev_name ${i} > /dev/null 2> /dev/null
        
    done
fi   
echo -e "\n"
   

for (( i=1;i<=$total_support_ns;i++ ))
do
    ${script_dir}/../../../micro/create_ns1.sh $dev_name 40960000 > /dev/null 2> /dev/null
    ${script_dir}/../../../micro/attach_ns1.sh $dev_name $i $controller_id > /dev/null 2> /dev/null 
done



${script_dir}/../../check_list/power_cycle.sh

echo "<Test scenario : end-to-end write verify test>"
for (( j=1;j<=$test_count;j++ ))
do
    echo "Test scenario progress :" $j"/"$test_count 
    for (( k=1;k<=$total_support_ns;k++ ))
  	  do
        for (( m=0 ; m<=1;m++ ))
        do
  	     echo "namespace$k formatting (--lbaf=1 --ms=$m --pi=1 --pil=0)"
  	     nvme format $dev_name --namespace-id=$k --lbaf=1 --ms=$m --pi=1 --pil=0
  	     
  	     	for (( l=0;l<=15;l++ ))
  	     	do
	       	echo "e2e write ${dev_name}n${k} (start block : 100, request_size :${request_size} sector, prinfo : $l)"  
#		${script_dir}/../../../micro/write-end.sh ${dev_name}n${k} 100 ${request_size} $l > /dev/null 2> /dev/null
	       	if [ $? -eq 0 ] ; then
	       		
	       		echo " -> success"	
	       	else
	       		
	       		echo " -> fail"	
	       	fi

	       	echo "e2e read ${dev_name}n${k} (start block : 100, request_size :${request_size} sector, prinfo : $l)"  
#	       	nvme read ${dev_name}n${k} --start-block=100 --block-count=$(($request_size-1)) --data-size=$(($request_size*512)) --metadata-size=8 --data=write_data.dat --metadata=meta_data.dat --prinfo=$l > /dev/null 2> /dev/null
	       	if [ $? -eq 0 ] ; then
	       		
	       		echo " -> success"	
	       	else
	       		
	       		echo " -> fail"	
	       	fi
  	     	done
  	       echo -e "\n"
        done
	done
    echo -e "\n"
done

${script_dir}/../../../micro/rm_remain_file.sh ${script_dir}

echo "<Device fault verify>"
${script_dir}/../../check_list/power_cycle.sh
${script_dir}/../../check_list/fail_test.sh ${dev_name} $0
