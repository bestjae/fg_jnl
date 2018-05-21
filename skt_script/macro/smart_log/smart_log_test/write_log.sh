#!/bin/bash

script_name=$1

while read line; do
    echo $line
    echo $line >> ${script_name}.log
done
