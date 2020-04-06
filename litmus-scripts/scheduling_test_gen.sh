#!/bin/bash
EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
TSK_FLD=$EXP_DIR/tasksets
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

mkdir $TSK_FLD
cp $GEN_SCRIPT $TSK_FLD
cd $TSK_FLD
for norm_u in $(seq 0.1 0.1 0.9)
do
  for((i=1;i<=$iteration;i++));
  do
    python $GEN_SCRIPT $m $p $duration $i $norm_u
  done
done
rm $GEN_SCRIPT

chmod +x *.sh

cd $CURR_DIR