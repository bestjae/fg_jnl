#! /bin/bash
# $1=/dev/device
#
FILE=`which file`

if [ ! -e $FILE ];then
exit -1
fi

if [ ! -e $1 ];then
exit -1
fi

str=`$FILE $1 | cut -d " " -f2`
echo $str

if [ $str == "character" ];then
    exit 1
elif [ $str == "block" ]; then
    exit 2   
else
    exit -1
fi
