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

cd $FT_DIR
./clean_all.sh
cd $ST_DIR
./clean_all.sh
cd $EXP_DIR

for((i=1;i<=$iteration;i++));
do
  #echo $i
  # python task_gen_vary_utilization.py $m $p $d $norm_u
  # ./st_test.sh $m $p $d $i $norm_u
  # ./ft_test.sh $m $p $d $i $norm_u
  ./exp.sh $m $p $duration $iteration
done



# for u in $(seq 0.1 0.1 1)
# do
#   # ./exp.sh $1 1 $2 $iteration $u
#   #./exp.sh $1 4 $2 $iteration $u
#   ./exp.sh $1 8 $2 $iteration $u
# done
