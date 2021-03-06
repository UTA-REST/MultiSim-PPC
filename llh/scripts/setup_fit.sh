#!/bin/bash
d=$1
cd $d
ll="*"
for b in *.dat
do
    echo "$b"
     cd /data/user/balatoum/dllh/old/llh/

    ./llh.sh 0 $b 36
    cd ..
    f=$(ls -d fit.$b-* | wc -l)
    cd fit.$b-1
    k=$(ls done | wc -l)
cd ..
     if test $k=0; then 
    cd llh/
 echo "HERE -->"$f 
    echo "Universe        = vanilla
Notification    = never
Executable      = run.sh

Output          = /home/balatoum/root/out/second_"$b"_\$(Process)
Error           = /home/balatoum/root/err/second_"$b"_\$(Process)
Log             = /home/balatoum/root/log/second_"$b"_\$(Process)

Arguments       = \$(Process) " $b "

request_gpus    = 1
request_memory  = 8GB

requirements    = regexp(\"(gtx-8|gtx-27|gtx-33|gtx-40|rad-0)\", Machine) != True

queue "$f >> condor.$b
fi
    cd scripts
     cd $d
done

echo "Done"
