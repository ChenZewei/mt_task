#!/bin/bash
EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

if [ "$#" -eq "5" ];
then
  m=$1
  p=$2
  d=$3
  iteration=$4
  norm_u=$5
else
  m=8
  p=4
  d=10
  iteration=1
  norm_u=1
fi

for((i=0;i<$iteration;i++));
do
  #echo $i
  # python task_gen_vary_utilization.py $m $p $d $norm_u
  # ./st_test.sh $m $p $d $i $norm_u
  # ./ft_test.sh $m $p $d $i $norm_u
  ./scheduling_test.sh $m $p $d $i $norm_u
done