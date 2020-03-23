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

setsched CG-FP

gap=`expr 5 + $duration / 1000`
gap=`expr $iteration \* $gap`

for norm_u in $(seq 0.1 0.1 1)
do
  sleep $gap | st-trace-schedule cgfp_m$1_p$2_d$3_u$5 &
  for((i=1;i<=$iteration;i++));
  do
    ../tasksets/global_${m}_${p}_${duration}_${i}_${norm_u}.sh &
    sleep 2
    release_ts &
    sleep `expr 3 + $duration / 1000`
  done
  wait
  st-job-stats -s *.bin > cgfp_result_${m}_${p}_${duration}_${norm_u}.txt
done