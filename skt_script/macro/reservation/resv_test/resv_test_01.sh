#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)
function nvme_set_hostid()
{
    echo -n -e \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x01 > $HOST1_ID_FILE

    hexdump $HOST1_ID_FILE

    echo ""
    echo "Set feature : " $HOST1_NVME_DEVICE
    nvme set-feature $HOST1_NVME_DEVICE --namespace-id=1 --feature-id=0x81 --value=$EXHID --data=$HOST1_ID_FILE --data-len=$HOST_ID_SIZE
	echo ""

    echo ""
    echo "Get feature : " $HOST1_NVME_DEVICE
    nvme get-feature $HOST1_NVME_DEVICE --namespace-id=1 --feature-id=0x81
	echo ""

    echo -n -e \\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02 > $HOST2_ID_FILE
    hexdump $HOST2_ID_FILE

    echo ""
    echo "Set feature : " $HOST2_NVME_DEVICE
    nvme set-feature $HOST2_NVME_DEVICE --namespace-id=1 --feature-id=0x81 --value=$EXHID --data=$HOST2_ID_FILE --data-len=$HOST_ID_SIZE
	echo ""

    echo ""
    echo "Get feature : " $HOST2_NVME_DEVICE
    nvme get-feature $HOST2_NVME_DEVICE --namespace-id=1 --feature-id=0x81
	echo ""
}

function nvme_register_key_test()
{
    NRKEY=0xa
    echo "Register Key" $NRKEY
    echo "Register Key" $HOST1_NVME_DEVICE --namespace-id=1 --nrkey=$NRKEY --rrega=$RREGA_REGISTER --cptpl=0 
    nvme resv-register $HOST1_NVME_DEVICE --namespace-id=1 --nrkey=$NRKEY --rrega=$RREGA_REGISTER --cptpl=0
	ret=`echo $?`
	if [ $ret -eq 0 ]; then
    	echo "Host1 register key success"
	else
		echo "Host1 register key fail"
	fi
	printf "\n"

    CRKEY=$NRKEY
    NRKEY=$((CRKEY + 1))
    echo "Replace Key" $CRKEY with  $NRKEY
    echo "Replace Key" $HOST1_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY --nrkey=$NRKEY --rrega=$RREGA_REPLACE --cptpl=0
    nvme resv-register $HOST1_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY --nrkey=$NRKEY --rrega=$RREGA_REPLACE --cptpl=0
	ret=`echo $?`
	if [ $ret -eq 0 ]; then
    	echo "Host1 register key success"
	else
		echo "Host1 register key fail"
	fi
	printf "\n"

    CRKEY=$NRKEY
    echo "Unregister Key" $CRKEY
    echo "Unregister Key" $HOST1_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY --rrega=$RREGA_UNREGISTER --cptpl=0
    nvme resv-register $HOST1_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY --rrega=$RREGA_UNREGISTER --cptpl=0
	ret=`echo $?
	if [ $ret -eq 0 ]; then
    	echo "Host1 register key success"
	else
		echo "Host1 register key fail"
	fi
	printf "\n"

    NRKEY=0xb
    echo "Register key" $NRKEY
    echo "Register Key" $HOST2_NVME_DEVICE --namespace-id=1 --nrkey=$NRKEY --rrega=$RREGA_REGISTER --cptpl=0 
    nvme resv-register $HOST2_NVME_DEVICE --namespace-id=1 --nrkey=$NRKEY --rrega=$RREGA_REGISTER --cptpl=0
	ret=`echo $?`
	if [ $ret -eq 0 ]; then
    	echo "Host1 register key success"
	else
		echo "Host1 register key fail"
	fi
	printf "\n"

    CRKEY=$NRKEY
    NRKEY=$((CRKEY + 1))
    echo "Replace Key" $CRKEY with  $NRKEY
    echo "Replace key" $HOST2_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY --nrkey=$NRKEY --rrega=$RREGA_REPLACE --cptpl=0 
    nvme resv-register $HOST2_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY --nrkey=$NRKEY --rrega=$RREGA_REPLACE --cptpl=0
	ret=`echo $?`
	if [ $ret -eq 0 ]; then
    	echo "Host1 register key success"
	else
		echo "Host1 register key fail"
	fi
	printf "\n"

    CRKEY=$NRKEY
    echo "Unregister Key" $CRKEY
    echo "Unregister Key" $HOST2_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY --rrega=$RREGA_UNREGISTER --cptpl=0 
    nvme resv-register $HOST2_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY --rrega=$RREGA_UNREGISTER --cptpl=0
	ret=`echo $?
	if [ $ret -eq 0 ]; then
    	echo "Host1 register key success"
	else
		echo "Host1 register key fail"
	fi
	printf "\n"
}

OUTPUT_FILENAME=resv_test_01.log

HOST1_NVME_DEVICE=/dev/nvme0
HOST1_ID_FILE=host_id1.dat

HOST2_NVME_DEVICE=/dev/nvme1
HOST2_ID_FILE=host_id2.dat

test_count=$1
argc=$#
if [ $argc -lt 1 ]; then
    echo "Usage : ./resv_test_01.sh [test_count]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

echo "<Test Environment Check>"
${script_dir}/../oncs_resv_check.sh $HOST1_NVME_DEVICE
resv_ret=$?
if [ $resv_ret -eq 1 ]; then
    echo "Reservation bit off"
    exit 1
else
    echo "Reservation bit on"
fi
rm oncs_log.txt

${script_dir}/../oncs_resv_check.sh $HOST2_NVME_DEVICE
resv_ret=$?
if [ $resv_ret -eq 1 ]; then
    echo "Reservation bit off"
    exit 1
else
    echo "Reservation bit on"
fi
rm oncs_log.txt
echo ""

HOST_ID_SIZE=8

EXHID=0 # Enable Extended Host Identifier (EXHID)

# set host id for host1 and host2
echo "<Test Environment initilazation>"
nvme_set_hostid

# Reservation Register Action
RREGA_REGISTER=0
RREGA_UNREGISTER=1
RREGA_REPLACE=2

# Reservation Type 
RTYPE_WRITE_EX=1
RTYPE_EX_ACCESS=2
RTYPE_WRITE_EX_REGISTRANT=3
RTYPE_EX_ACCESS_REGISTRANT=4
RTYPE_WRITE_EX_ALL=5
RTYPE_EX_ACCESS_ALL=6

# Reservation Acquire Action
RACQA_ACQUIRE=0
RACQA_PREEMPT=1
RACQA_PREEMPT_ABORT=2

# Reservation Release Action
RRELA_RELEASE=0
RRELA_CLEAR=1

# Register Key Test
echo "<Test scenario : Register/Unregister Key Test>" 
echo "Test Progress :" $i"/"$test_count

for (( i=1;i<=$test_count;i++ ))
do
    nvme_register_key_test
done

rm $HOST1_ID_FILE
rm $HOST2_ID_FILE
