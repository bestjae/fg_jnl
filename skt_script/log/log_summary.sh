#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
ex=`echo $script_dir | tr -cd "/" | wc -m`
grep -rn "fail" --exclude="log_summary.sh" ${script_dir} > ${script_dir}/total_fail_log.txt

namespace_fail=0
namespace_io_fail=0
dsm_fail=0
firmware_fail=0
smrat_log_fail=0
reservation_fail=0
e2e_fail=0
fail=0

while read line; do
	#echo $line
	category=`echo $line | cut -d'/' -f$((${ex}+2))`
	#echo $category
	if [ "$category" == "namespace" ]; then
		namesapce_fail=$(($namespace_fail+1))
	elif [ "$category" == "namespace_io" ]; then
		namespace_io_fail=$(($namespace_io_fail+1))
	elif [ "$category" == "dsm" ]; then
		dsm_fail=$(($dsm_fail + 1))
	elif [ "$category" == "firmware" ]; then
		firmware_fail=$(($firmware_fail+1)) 
	elif [ "$category" == "smart_log" ]; then
		smart_log_fail=$(($smart_log_fail + 1))
	elif [ "$category" == "reservation_log" ]; then
		reservation_log_fail=$(($reservation_log_fail+1))
	elif [ "$category" == "e2e" ]; then
		e2e_fail=$(($e2e_fail+1))
	else
		echo $line
		fail=$(($fail+1))
		echo $category
	fi	
done < ${script_dir}/total_fail_log.txt

echo "Namespace fail             : " $namespace_fail
echo "Namespace+I/O fail         : " $namespace_io_fail
echo "DSM fail                   : " $dsm_fail
echo "Firmware fail              : " $firmware_fail
echo "SMART log fail             : " $smart_log_fail
echo "Reservation fail           : " $reservation_fail
echo "End-to-End Protection fail : " $e2e_fail
echo "Other fail                 : " $fail
echo "--------------------------------------"
echo "Total fail command         : " $(($namespace_fail+$namespace_io_fail+$dsm_fail+$firmware_fail+$smart_log_fail+$reservation_fail+$e2e_fail+$fail))

