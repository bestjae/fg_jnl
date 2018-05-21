#!/bin/bash

argc=$#
dev_name=$1
test_count=$2
script_dir=$(cd "$(dirname "$0")" && pwd)
firmware_dir=${script_dir}/crab/2016-12-02_72a1e481_SKT_SSD_U2_RevB/

#Create Log directory
mkdir ${script_dir}/log > /dev/null 2> /dev/null

# Power_Cycle_option Setting
NPOR_PC=1   #    Power Cycle,    rmmod, modprobe
SPOR_PC=2   #    Power Cycle, No rmmod, modprobe
ONLY_MD=3   # No Power Cycle,    rmmod, modprobe
NO_PC=4   	# No Power Cycle, No rmmod, modprobe

PC_OPTION=$NPOR_PC
echo $PC_OPTION > ${script_dir}/macro/check_list/power_option


if [ $argc -lt 2 ]; then
    echo "Usage : ./start_all_functionality_test.sh [device] [test_count]"
    exit 1
fi

#echo "NAMESPACE FUNCTIONALITY TEST"
#echo -e "\n"
#${script_dir}/macro/namespace/ns_test/start_ns_management_test.sh $dev_name $test_count
#${script_dir}/macro/namespace/ns_test/start_format_test.sh $dev_name $test_count
#${script_dir}/macro/namespace/ns_test/start_extra_test.sh $dev_name $test_count

#echo "NAMSPACE + I/O FUNCTIONALITY TEST"
#echo -e "\n"
#${script_dir}/macro/namespace_io/nsio_test/start_nsio_test.sh $dev_name $test_count

#echo -e "\n"
#echo "SMARTLOG FUNCTIONALITY TEST"
#${script_dir}/macro/smart_log/smart_log_test/start_smartlog_test.sh $dev_name $test_count

#echo "DSM FUNCTIONALITY TEST"
#echo -e "\n"
#${script_dir}/macro/dsm/dsm_test/start_dsm_test.sh $dev_name $test_count

#echo "FIRMWARE FUNCTIONALITY TEST"
#echo "Current firmware version :" $firmware_dir
#echo -e "\n"
#${script_dir}/macro/firmware/start_firmware_test.sh $dev_name $firmware_dir $test_count

#echo "RESERVATION FUNCTIONALITY TEST" 
#echo -e "\n"
#${script_dir}/macro/reservation/resv_test/start_resv_test.sh $test_count

#echo "END-TO-END PROTECTION FUNCTIONALITY TEST"
#echo -e "\n"
#${script_dir}/macro/end-to-end/e2e_test/start_e2e_test.sh $dev_name $test_count

echo "All Test End!"
${script_dir}/log/log_summary.sh
echo "Total Log summary file path :" ${script_dir}"/log"
printf "\n"


