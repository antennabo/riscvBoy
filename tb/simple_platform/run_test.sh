#!/bin/bash

#
if [ $# -eq 0 ]; then
    echo "Usage: $0 <testcase>"
    exit 1
fi

TESTCASE=$1  #
rm -rf cpu_wave.vcd
#
iverilog -DTESTCASE="\"$TESTCASE\"" -v -DDEBUG -o cpu_sim -f filelist_tb.f

# 
vvp cpu_sim

# 
gtkwave cpu_wave.vcd &

