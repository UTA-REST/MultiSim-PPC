#!/bin/bash
d=$1
cd $d
for b in *.dat
do
    echo "$b"
     cd /data/user/balatoum/dllh/old/llh/
    condor_submit condor.$b
    cd $d
done
