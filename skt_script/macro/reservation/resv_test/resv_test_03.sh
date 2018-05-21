#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)

function nvme_acquire_release()
{
    echo ""
    for RTYPE in $RTYPE_WRITE_EX $RTYPE_EX_ACCESS $RTYPE_WRITE_EX_REGISTRANT $RTYPE_EX_ACCESS_REGISTRANT $RTYPE_WRITE_EX_ALL $RTYPE_EX_ACCESS_ALL 
    do
        echo "" 
        echo "<RTYPE" $RTYPE ">"

		if [ $RACQA -eq $RACQA_PREEMPT ] || [ $RACQA -eq $RACQA_PREEMPT_ABORT ]; then
            PRKEY_HOST2=$((CRKEY_HOST2))
        fi

        echo "Reservation Acquire" $HOST1_NVME_DEVICE Current key=$CRKEY_HOST1 Rtype=$RTYPE RACQA=$RACQA_ACQUIRE 
        nvme resv-acquire $HOST1_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY_HOST1 --rtype=$RTYPE --racqa=$RACQA_ACQUIRE
        echo Host1 acquire return $? 
		printf "\n"

        if [ $RACQA -eq $RACQA_PREEMPT ] || [ $RACQA -eq $RACQA_PREEMPT_ABORT ]; then
            echo "Reservation Acquire" $HOST2_NVME_DEVICE Current key=$CRKEY_HOST2 Preempt Key=$CRKEY_HOST1 Rtype=$RTYPE RACQA=$RACQA 
            nvme resv-acquire $HOST2_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY_HOST2 --prkey=$CRKEY_HOST1 --rtype=$RTYPE --racqa=$RACQA
        else
            echo "Reservation Acquire" $HOST2_NVME_DEVICE Current key=$CRKEY_HOST2 Rtype=$RTYPE RACQA=$RACQA 
            nvme resv-acquire $HOST2_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY_HOST2 --rtype=$RTYPE --racqa=$RACQA
        fi

        echo Host2 acquire return $? 
		printf "\n"

        if [ $RACQA -eq $RACQA_PREEMPT ] || [ $RACQA -eq $RACQA_PREEMPT_ABORT ]; then
            CRKEY_HOST2=$PRKEY_HOST2
        fi

        FILESIZE=512
        FILENAME_WRITE=data_${FILESIZE}_write.dat
        FILENAME_READ=data_${FILESIZE}_read.dat

        dd if=/dev/urandom of=$FILENAME_WRITE bs=$FILESIZE count=1 2> /dev/null

        echo "Host1 Read/Write I/O with Reservation"
        echo "write ${HOST1_NVME_DEVICE}n1 --start-block=0 --block-count=0 --data-size=$FILESIZE --data=$FILENAME_WRITE"
        nvme write ${HOST1_NVME_DEVICE}n1 --start-block=0 --block-count=0 --data-size=$FILESIZE --data=$FILENAME_WRITE
		ret=$?
		if [ $ret -eq 0 ]; then
			echo "Host1 Write with Reservation scueess"
		else
			echo "Host1 Write with Reservation fail"
		fi

        echo "read ${HOST1_NVME_DEVICE}n1 --start-block=0 --block-count=0 --data-size=$FILESIZE --data=$FILENAME_WRITE"
        nvme read ${HOST1_NVME_DEVICE}n1 --start-block=0 --block-count=0 --data-size=$FILESIZE --data=$FILENAME_READ
		ret=$?
		if [ $ret -eq 0 ]; then
			echo "Host1 Read with Reservation scueess"
		else
			echo "Host1 Read with Reservation fail"
		fi
		printf "\n"


        echo "Host2 Read/Write I/O with Reservation"
        echo "write ${HOST2_NVME_DEVICE}n1 --start-block=0 --block-count=0 --data-size=$FILESIZE --data=$FILENAME_WRITE"
        nvme write ${HOST2_NVME_DEVICE}n1 --start-block=0 --block-count=0 --data-size=$FILESIZE --data=$FILENAME_WRITE
		ret=$?
		if [ $ret -eq 0 ]; then
			echo "Host2 Write without Reservation scueess"
		else
			echo "Host2 Write without Reservation fail"
		fi

        echo "read ${HOST2_NVME_DEVICE}n1 --start-block=0 --block-count=0 --data-size=$FILESIZE --data=$FILENAME_READ"
        nvme read ${HOST2_NVME_DEVICE}n1 --start-block=0 --block-count=0 --data-size=$FILESIZE --data=$FILENAME_READ
		ret=$?
		if [ $ret -eq 0 ]; then
			echo "Host2 Read without Reservation scueess"
		else
			echo "Host2 Read without Reservation fail"
		fi
		printf "\n"

        echo "Reservation Release" Current Key=$CRKEY_HOST1 Rtype=$RTYPE RRELA=$RRELA 
        nvme resv-release $HOST1_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY_HOST1 --rtype=$RTYPE --rrela=$RRELA
        echo Host1 release return $? 

        echo "Reservation Release" Current Key=$CRKEY_HOST2 Rtype=$RTYPE RRELA=$RRELA 
        nvme resv-release $HOST2_NVME_DEVICE --namespace-id=1 --crkey=$CRKEY_HOST2 --rtype=$RTYPE --rrela=$RRELA
        echo Host2 release return $? 

        rm $FILENAME_WRITE
        rm $FILENAME_READ
    done
    echo -e "\n" 
}

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
    echo ""
    nvme get-feature $HOST1_NVME_DEVICE --namespace-id=1 --feature-id=0x81

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

function nvme_register_key()
{
    echo "Register Key" $1 $2
    nvme resv-register $1 --namespace-id=1 --nrkey=$2 --rrega=$RREGA_REGISTER --cptpl=0
}

function nvme_unregister_key()
{
    echo "Unregister Key" $1 $2
    nvme resv-register $1 --namespace-id=1 --crkey=$2 --rrega=$RREGA_UNREGISTER --cptpl=0
}

function reservation_test_main()
{
    # Register Key for test
    NRKEY=0xa
    NRKEY_HOST1=$((NRKEY + 1))
    NRKEY_HOST2=$((NRKEY + 2))
    nvme_register_key $HOST1_NVME_DEVICE $NRKEY_HOST1
    echo ""
    echo "Host 1 is a registrant." 

    if [ $HOST2_REGISTRANT -eq 1 ]; then
        nvme_register_key $HOST2_NVME_DEVICE $NRKEY_HOST2
        echo "Host 2 is a registrant."
    else
        echo "Host 2 is a non-registrant."
    fi

    CRKEY_HOST1=$NRKEY_HOST1
    CRKEY_HOST2=$NRKEY_HOST2

    RACQA=$RACQA_ACQUIRE
    RRELA=$RRELA_RELEASE
    echo "" 
    echo "Acquire Action: Acquire ($RACQA)" 
    nvme_acquire_release

    RACQA=$RACQA_PREEMPT
    echo "" 
    echo "Acquire Action: Preempt ($RACQA)" 
    RRELA=$RRELA_RELEASE
    nvme_acquire_release

    RACQA=$RACQA_PREEMPT_ABORT
    echo "" 
    echo "Acquire Action: Preempt Abort ($RACQA)" 
    RRELA=$RRELA_RELEASE
    nvme_acquire_release

    # Unregister Key 
    nvme_unregister_key $HOST1_NVME_DEVICE $NRKEY_HOST1
    if [ $HOST2_REGISTRANT -eq 1 ]; then
        nvme_unregister_key $HOST2_NVME_DEVICE $NRKEY_HOST2
    fi
}


HOST1_NVME_DEVICE=/dev/nvme0
HOST1_ID_FILE=host_id1.dat

HOST2_NVME_DEVICE=/dev/nvme1
HOST2_ID_FILE=host_id2.dat

argc=$#
test_count=$1

if [ $argc -lt 1 ]; then
    echo "Usage : ./resv_test_03.sh [test_count]"
    ${script_dir}/../../../micro/input_error_exit.sh
fi

echo "<Environment check>"
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

HOST_ID_SIZE=8

EXHID=0 # Enable Extended Host Identifier (EXHID)

# set host id for host1 and host2
echo "<Test initialization>"
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

# Reservation Conflict for Non-Registrant
echo "<Test scenario : Reservation Conflict for Non-Registrant Test>"
echo "Host2 Registrant : " $HOST2_REGISTRANT ", Non-Registrant"

for ((i=1;$i<=$test_count;i++))
do
    HOST2_REGISTRANT=0
	echo "Test Progress :" $i"/"$test_count
    reservation_test_main
done

rm $HOST1_ID_FILE
rm $HOST2_ID_FILE
