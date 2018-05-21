#!/bin/bash

script_dir=$1

find ${script_dir} -name '*.txt' -exec rm -r {} \;
find ${script_dir} -name '*.dat' -exec rm -r {} \;
find ${script_dir} -name '*.bin' -exec rm -r {} \;

find ${script_dir}/../ -name '*.txt' -exec rm -r {} \;
find ${script_dir}/../ -name '*.dat' -exec rm -r {} \;
find ${script_dir}/../ -name '*.bin' -exec rm -r {} \;

#find ./nsio_test -name '*.txt' -exec rm -r {} \;
#find ./nsio_test -name '*.dat' -exec rm -r {} \;
#
#find . -name '*.txt' -exec rm -r {} \;
#find . -name '*.dat' -exec rm -r {} \;
