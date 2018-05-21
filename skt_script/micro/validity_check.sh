#! /bin/bash 

 script_dir=$(cd "$(dirname "$0")" && pwd)

check_test=$1
ret=$2
dev_name=$3

script_name=`echo $1 | rev | cut -d'/' -f1 | rev`

case $script_name in
attach_ns1.sh)
    attach_namespace_id=$4
	global_ns=`cat ${script_dir}/ns`
	if [ $ret -eq 0 ]; then
        echo "" > /dev/null 2> /dev/null
	elif [ $ret -eq 2 ]; then
		echo "-> attach-ns (purpose of testing)"
	    exit 0
	else
	    echo "attach-ns commnad fail"
	    echo "attach-ns end..."
	    exit 1
	fi


    if [ $global_ns -ne 0 ]; then
	    nvme list-ns $dev_name --all  > ${script_dir}/list-ns.txt
	    list_ns=`${script_dir}/list-ns-parsing.sh`
	    array=( ${list_ns} )
        total_ns=`echo ${#array[*]}`
	    
	    for ((i=0;$i<total_ns;i++))
	    do
	        if [ ${array[$i]} -eq $attach_namespace_id ] ; then
	            exit 0
	        fi
	    done
	
	    if [ $i -eq $total_ns ]; then
	        echo "attach-ns function fail"
	        echo "attach-ns end..."
	        exit 1
        fi
	fi
	
;;
create_ns1.sh)
	global_ns=`cat ${script_dir}/ns`
    before_total_ns=$global_ns
	if [ $ret -eq 0  ]; then
        global_ns=`expr ${global_ns} + 1`
	    echo ${global_ns} > ${script_dir}/ns
	elif [ $ret -eq 21 ]; then
		echo "-> create-ns (purpose of testing)"
	    exit 0
	else
	    echo "create-ns command fail"
	    echo "create-ns end..."
	    exit 1
	fi
	
	if [ $global_ns -ne 0 ]; then
	    nvme list-ns $dev_name  > ${script_dir}/list-ns.txt 
	    list_ns=`${script_dir}/list-ns-parsing.sh`
	    array=( $list_ns )
        after_total_ns=`echo ${#array[*]}`
	    echo $after_total_ns > ${script_dir}/ns
	
	    if [ $before_total_ns = $after_total_ns ] ; then
	        echo "create-ns function fail"
	        echo "create-ns end..."
	        exit 1
	    else
	        exit 0
	    fi
	else
	    exit 0
	
	fi
	exit 0

;;
delete_ns1.sh)
    del_namespace_id=$4
	global_ns=`cat ${script_dir}/ns`
	if [ $ret -eq 0 ]; then
	    global_ns=`expr ${global_ns} - 1`
        echo ${global_ns} > ${script_dir}/ns
	elif [ $ret -eq 11 ]; then
		echo "-> delete-ns (purpose of testing)"
	    exit 0
	elif [ $ret -eq 2 ]; then
		echo "-> delete-ns (purpose of testing)"
	    exit 0
	else
	    echo "delete-ns command fail"
	    echo "delete-ns end..."
	    exit 1
	fi
	
	if [ $global_ns -ne 0 ]; then
	    nvme list-ns $dev_name  > ${script_dir}/list-ns.txt
	    list_ns=`${script_dir}/list-ns-parsing.sh`
	    array=( ${list_ns} )
        total_ns=`echo ${#array[*]}`
	    echo $total_ns > ${script_dir}/ns    

	    for ((i=0;$i<total_ns;i++))
	    do
	        if [ ${array[$i]} -eq $del_namespace_id ] ; then
	            echo "delete-ns function fail"
	            echo "delete-ns end..."
	            exit 1
	        fi
	    done
	    exit 0
	else
	    exit 0
	fi
	exit 0
;;

detach_ns1.sh)
    det_namespace_id=$4
	global_ns=`cat ${script_dir}/ns`
	if [ $ret -eq 0 ]; then
        echo "" > /dev/null 2> /dev/null
	elif [ $ret -eq 26 ]; then
		echo "-> detach-ns (purpose of testing)"
	    exit 0
	elif [ $ret -eq 2 ]; then
		echo "-> detach-ns (purpose of testing)"
	    exit 0
	elif [ $ret -eq 11 ]; then
		echo "-> detach-ns (purpose of testing)"
	    exit 0
	else
		echo "detach-ns command fail"
	    echo "detach-ns end..."
	    exit 1
	fi
	
	if [ $global_ns -ne 0 ]; then
		nvme list-ns $dev_name --all  > ${script_dir}/list-ns.txt 
		list_ns=`${script_dir}/list-ns-parsing.sh`
		array=( ${list_ns} )
        total_ns=`echo ${#array[*]}`
		
		for ((i=0;$i<total_ns;i++))
		do
		    if [ ${array[$i]} = $det_namespace_id ]; then
		        echo "detach-ns function fail"
		        exit 1
		    fi
		done
	
	    exit 0
	else
	    exit 1
	fi
	
	exit 0
;;
esac

exit 1
