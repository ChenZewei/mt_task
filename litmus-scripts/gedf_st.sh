sdf#!/bin/bash
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

for norm_u in $(seq 0.1 0.1 1)
do
  for((i=1;i<=$iteration;i++));
  do
    ./tasksets/global_${m}_${p}_${duration}_${i}_${norm_u}.sh
    release_ts
  done
done