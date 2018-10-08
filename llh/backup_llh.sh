#!/bin/bash

ice=../ice
ppc=../gpu/ppc
. ../ocl/src
. ../llh/src

strings=`seq 1 86`

if test $# -gt 0; then echo -n $*: `date`; fi

m=0
k=$[$1+0]
a=$1
q=$2
ICEM="/icemodels/Amp/"
ICEM+=$2
echo "HERE"
if test "$FWID" = ""; then FWID=12; fi
if test "$SREP" = ""; then SREP=10; fi


for str in $strings; do
    if test $k = 0; then LYS=`seq 1 60`; m=-1
    else

	xy=`awk $str=='$6 && $7>=1 && $7<=60 {x+=$3; y+=$4; n++} END {print x/n, y/n}' $ice/geo-f2k `
	kz=`PPCTABLESDIR=$ice $ppc - $xy 2>/dev/null | awk 'NR==172-'$k' {print 1948.07-$1}'`

	LYS=`awk $str=='$6 && $7>=1 && $7<=60 {dz='$kz'+$5; if(dz<0) dz=-dz; print dz, $7}' $ice/geo-f2k |
	sort -g | head -5 | sort -k2,2n | awk '$1<100 {print $2}'`

    fi

    echo $str $LYS | awk 'BEGIN {while(getline<"cdom.txt") a[$1]++} {s=$1; printf s; for(i=2; i<=NF; i++){ if(!(s"_"$i in a)) printf " "$i; } printf "\n" }'
done > lys.txt

for b in $q""; do
n=0
for str in $strings; do

    det=86

    for dom in `awk '$1=='$str' {$1=""; print}' lys.txt`; do
	fla=${str}_$dom
	dat=../dat/all/oux.$fla

	if test -e $dat; then 
	    if ! test -d ../fit.$b-$n; then
		num=`cat ../dat/all/num.$fla`

		if ! test -e ../fit.$b-$n; then
		    mkdir ../fit.$b-$n
		    echo $fla > ../fit.$b-$n/fla
		    ln -sf $dat ../fit.$b-$n/dat
#		    ln -sf ../llh/as ../fit.$b-$n/
#		    ln -sf ../llh/zs ../fit.$b-$n/
#		    ln -sf ../llh/cx ../fit.$b-$n/
#		    ln -sf ../llh/cs ../fit.$b-$n/
#		    ln -sf ../llh/dx ../fit.$b-$n/

		    ( cat ../ice/bad-f2k ../dat/detector/bad.ic$det; echo $str $dom; awk '$1=='$str' && $2=='$dom' {print $3, $4}' list.bad ) > ../fit.$b-$n/bad

		    echo "time PPCTABLESDIR=$ice/$b FWID=$FWID SREP=$SREP DREP=$num FLSH=$fla FAIL=1 FAST=0 MLPD=1 CYLR=1 FLOR=0 FSEP=1 GSL_RNG_SEED=$RANDOM \$llh $m" > ../fit.$b-$n/run
		fi
	    fi
	    n=$[$n+1]
	fi
    done

done
done

set -o pipefail

echo "done"
for b in $q""; do
    while true; do
	for i in ../fit.*; do
	    ls -la $i >& /dev/null
	    if test -d $i && test -e $i/host && ! test -e $i/done; then
		t1=`ls --time-style="+%s" -ltr $i 2>> llh.log | tee llh.foo | awk 'END {print $6}'`
		endc=$?; if test $endc -gt 0; then cat llh.foo >> llh.log; fi
		t2=`date "+%s"`
		if test $endc -ge 0 && test $[$t2-$t1] -gt $[10*60]; then echo rm $i/host 2>> llh.log; fi
	    fi
	done

	for i in ../fit.$b-*; do ls -la $i >& /dev/null; done
	if test `ls ../fit.$b-*/done 2>/dev/null | wc -l`"" -eq "$n"; then break; fi
	sleep 10
    done

    for i in `seq 0 $[$n-1]`; do cat ../fit.$b-$i/log 1>&2; cat ../fit.$b-$i/{fla,out}; done 2>tmp/log.$a.$b |
    tee tmp/out.$a.$b | awk '/^[?*]/ { llh+=$2; } END {print llh}' | tee tmp/a.$a.$b | awk '{printf " "$0}'
done

grep Error tmp/log.$a.*

echo "DONE"
d=`mktemp -d tmp/run-XXXXXX`
mv ../fit.* $d 2>/dev/null

while test -e stop; do echo -n "." 1>&2; sleep 100; done
