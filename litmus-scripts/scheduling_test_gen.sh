#!/bin/bash
EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
GEN_SCRIPT=task_gen_vary_utilization.py
# GEN_SCRIPT=task_gen_vary_utilization_random_period.py
CURR_DIR=`pwd`

m=8
p=8
duration=1000
iteration=1
m=$1
p=$2
duration=$3
iteration=$4

mkdir $ST_DIR/tasksets
cp $GEN_SCRIPT $ST_DIR/tasksets
cd $ST_DIR/tasksets
for norm_u in $(seq 0.1 0.1 1)
do
  for((i=1;i<=$iteration;i++));
  do
    python $GEN_SCRIPT $m $p $duration $i $norm_u
  done
done
rm $GEN_SCRIPT

chmod +x *.sh

cd $CURR_DIR