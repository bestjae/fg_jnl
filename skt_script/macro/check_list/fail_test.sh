#/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)

argc=$#
dev_name=$1
filename=$2
ret=$?

#check 1
#nvme list > ${script_dir}/result.txt &
#${script_dir}/../../macro/check_list/check_reboot.sh nvme list
#ret=`echo $?`
#
#if [ $ret -eq 1 ]; then
#    echo "$2 test fail"
#	echo "Press CTRL+c for stop"
#	for((;;))
#	do
#		echo 1 > /dev/null
#		sleep 1
#	done
#    exit 1
#fi

#check 2
nvme list > ${script_dir}/result.txt &
check=`cat ${script_dir}/result.txt`
not_exist="No NVMe devices detected."

if [ "$check" = "$not_exist" ] ; then
	echo "NVMe dead"
    echo "NVMe device detected fail (device check 2)"
	exit 1
fi

echo "NVMe device detected success (device check 2)"

#check3 --> i/o verify

start_block=0
request_size=10
read_size=10
test_count=1

${script_dir}/../../micro/get_support_ns.sh $dev_name
total_support_ns=`echo $?`

for (( i=1;i<=$total_support_ns;i++ ))
do
	${script_dir}/../../micro/delete_ns1.sh $dev_name ${i} > /dev/null 2> /dev/null
    ${script_dir}/../../micro/create_ns1.sh $dev_name 40960000 > /dev/null 2> /dev/null
    ${script_dir}/../../micro/attach_ns1.sh $dev_name $i $controller_id > /dev/null 2> /dev/null
done

global_ns=`cat ${script_dir}/../../micro/ns`
if [ $global_ns -eq 0 ]; then
    echo "No namespace for delete"
else
    nvme list-ns $dev_name  > ${script_dir}/list-ns.txt
    nvme_list=`${script_dir}/list-ns-parsing.sh`
    array=( ${nvme_list} )
    list_num=${#nvme_list}
    temp=`expr $list_num + 1`
    total_ns=`expr $temp \/ 2`
   
    for ((j=0;$j<test_count;j++))
    do
    	for ((i=0;$i<total_ns;i++))
    	do
			#echo "write ${dev_name}n${array[$i]} $start_block $request_size"
			${script_dir}/../../micro/write.sh ${dev_name}n${array[$i]} $start_block $request_size > /dev/null 2>/dev/null
			#echo "read ${dev_name}n${array[$i]} $start_block $request_size"
            ${script_dir}/../../micro/read.sh ${dev_name}n${array[$i]} $start_block $read_size > /dev/null 2>/dev/null
	       	start_block=`expr $start_block \+ 10`
			${script_dir}/../check_list/check_diff.sh ${script_dir}/write_data.dat ${script_dir}/read_data.dat  > /dev/null 2> /dev/null
			
			if [ $? -eq 1  ] ; then
				echo "$1 i/o verify test fail"
				exit 1
			fi 
		done
	done

fi   
echo "NVMe I/O verify test success (device check 3)"
rm ${script_dir}/result.txt
rm ${script_dir}/list-ns.txt

exit 0
