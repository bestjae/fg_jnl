#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
while read line
do
    namespace_id=${line:9}
    namespace_id=`echo $namespace_id | tr '[a-z]' '[A-Z]'`
    echo "obase=10; ibase=16;$namespace_id" | bc
done < ${script_dir}/list-ns.txt
