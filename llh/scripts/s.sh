#!/bin/bash
d=$1
cd $d
for b in *.dat
do
    echo "$b"
     cd /data/user/balatoum/dllh/old/llh/

    ./llh.sh 0 $b 36
    touch condor.$b
    f= ls ../fit.$b* | wc -l
    echo "Universe        = vanilla
Notification    = never
Executable      = run.sh

Output          = /home/balatoum/root/out/second_$b_\$\(Process)
Error           = /home/balatoum/root/err/second_$b_\$\(Process)
Log             = /home/balatoum/root/log/second_$b_\$\(Process)

Arguments       = \$\(Process)

request_gpus    = 1
request_memory  = 8GB

requirements    = regexp(\"(gtx-8|gtx-27|gtx-33|gtx-40|rad-0)\", Machine) != True

queue $f" >> condor.$b
    cd scripts
     cd $d
done

echo "Done"
