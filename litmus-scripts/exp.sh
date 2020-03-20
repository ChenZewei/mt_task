#!/bin/bash
EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

m=8
p=8
duration=1000
iteration=1
m=$1
p=$2
duration=$3
iteration=$4


for u in $(seq 0.1 0.1 1)
do
  # ./exp.sh $1 1 $2 $iteration $u
  #./exp.sh $1 4 $2 $iteration $u 
  ./scheduling_test.sh $m $p $duration $iteration $u
done

cd $ST_DIR/gedf
rm gedf_ratio_m$1_p$2_d$3.txt

cd $ST_DIR/cgedf
rm cgedf_ratio_m$1_p$2_d$3.txt

cd $ST_DIR/hc_cgedf
rm hc_cgedf_ratio_m$1_p$2_d$3.txt

for u in $(seq 0.1 0.1 1)
do
  cd $ST_DIR/gedf
  s=`grep "1" result_m$1_p$2_d$3_u$u.txt| wc -l`
  echo "scale=3;$s/$iteration" | bc >> gedf_ratio_m$1_p$2_d$3.txt

  cd $ST_DIR/cgedf
  s=`grep "1" result_m$1_p$2_d$3_u$u.txt| wc -l`
  echo "scale=3;$s/$iteration" | bc >> cgedf_ratio_m$1_p$2_d$3.txt

  cd $ST_DIR/hc_cgedf
  s=`grep "1" result_m$1_p$2_d$3_u$u.txt| wc -l`
  echo "scale=3;$s/$iteration" | bc >> hc_cgedf_ratio_m$1_p$2_d$3.txt
done
