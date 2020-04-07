#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
TSK_FLD=$EXP_DIR/tasksets

cd $TSK_FLD
duration=$1

for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset &`
sleep 2
release_t &
sleep $duration
done

# cd $FT_DIR
# cd $FT_DIR/gedf
# ./clean.sh
# setsched GSN-EDF
# cd $TSK_FLD
# ./global_edf_$1_$2_$3_$4_$5.sh &
# sleep 2
# cd $FT_DIR/gedf
# sleep `expr 3 + $3 / 1000` | ft-trace-overheads gedf_$1_$2_$3_$4_$5 &
# sleep 1
# release_ts &
# wait
# ./ft.sh gedf_$1_$2_$3_$4_$5



