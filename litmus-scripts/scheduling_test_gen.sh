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

mkdir tasksets
cp task_gen_vary_utilization.py tasksets
cd tasksets
for norm_u in $(seq 0.1 0.1 1)
do
  for((i=1;i<=$iteration;i++));
  do
    python task_gen_vary_utilization.py $m $p $duration $i $norm_u
  done
done
rm task_gen_vary_utilization.py

cd ..