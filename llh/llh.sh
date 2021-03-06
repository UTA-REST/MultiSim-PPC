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
s=$3
echo $s
ICEM="/twoshifts/"
ICEM+=$2
if test "$FWID" = ""; then FWID=12; fi
if test "$SREP" = ""; then SREP=10; fi


for str in $strings; do
    if test $k = 0; then LYS=`seq 1 60`; m=-1
    else

	xy=`awk $str=='$6 && $7>=1 && $7<=60 {x+=$3; y+=$4; n++} END {print x/n, y/n}' $ice/geo-f2k `
	kz=`PPCTABLESDIR=$ice ICEM=$ICEM $ppc - $xy 2>/dev/null | awk 'NR==172-'$k' {print 1948.07-$1}'`

	LYS=`awk $str=='$6 && $7>=1 && $7<=60 {dz='$kz'+$5; if(dz<0) dz=-dz; print dz, $7}' $ice/geo-f2k |
	sort -g | head -5 | sort -k2,2n | awk '$1<100 {print $2}'`

    fi

    echo $str $LYS | awk 'BEGIN {while(getline<"cdom.txt") a[$1]++} {s=$1; printf s; for(i=2; i<=NF; i++){ if(!(s"_"$i in a)) printf " "$i; } printf "\n" }'
done > lys.txt

for b in $q""; do
echo $b
n=0
for str in $strings; do

    det=86
  if test $str == $s; then 
      echo $str 
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

		    echo "time PPCTABLESDIR=$ice/ ICEM=$ICEM FWID=$FWID SREP=$SREP DREP=$num FLSH=$fla FAIL=1 FAST=0 MLPD=1 CYLR=1 FLOR=0 FSEP=1 GSL_RNG_SEED=$RANDOM \$llh $m" > ../fit.$b-$n/run
		fi
	    fi
	    n=$[$n+1]
	fi
    done
   fi

done
done

set -o pipefail

echo "done"
