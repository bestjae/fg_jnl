#!/bin/bash

script_dir=$(cd "$(dirname "$0")" && pwd)

HOST1_NVME_DEVICE=/dev/nvme0
HOST1_ID_FILE=host_id1.dat

HOST2_NVME_DEVICE=/dev/nvme1
HOST2_ID_FILE=host_id2.dat

HOST_ID_SIZE=8

EXHID=0 # Enable Extended Host Identifier (EXHID)


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

