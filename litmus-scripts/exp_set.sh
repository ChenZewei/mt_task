#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

iteration=1
iteration=$3

cd $FT_DIR
./clean_all.sh
cd $ST_DIR
./clean_all.sh
cd $EXP_DIR

for u in $(seq 0.1 0.1 1)
do
  # ./exp.sh $1 1 $2 $iteration $u
  # ./exp.sh $1 4 $2 $iteration $u
  ./exp.sh $1 8 $2 $iteration $u
done
