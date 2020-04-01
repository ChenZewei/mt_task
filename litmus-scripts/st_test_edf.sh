#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
TSK_FLD=$EXP_DIR/tasksets

cd $EXP_DIR

cd $ST_DIR
cd $ST_DIR/gedf
./clean.sh
setsched GSN-EDF
cd $TSK_FLD
./global_edf_$1_$2_$3_$4_$5.sh &
sleep 1
cd $ST_DIR/gedf
sleep `expr 3 + $3 / 1000` | st-trace-schedule gedf_$1_$2_$3_$4_$5 &
sleep 1
release_ts &
wait
st-job-stats -s *.bin > gedf_$1_$2_$3_$4_$5.txt
st-job-stats -S *.bin >> gedf_result_$1_$2_$3_$5.txt
# st-job-stats -R *.bin >> gedf_details_$1_$2_$3_$5.csv
# ./st.sh gedf_$1_$2_$3_$4_$5

cd $ST_DIR/cgedf
./clean.sh
setsched CG-EDF
cd $TSK_FLD
./global_edf_$1_$2_$3_$4_$5.sh &
sleep 1
cd $ST_DIR/cgedf
sleep `expr 3 + $3 / 1000` | st-trace-schedule cgedf_$1_$2_$3_$4_$5 &
sleep 1
release_ts &
wait
st-job-stats -s *.bin > cgedf_$1_$2_$3_$4_$5.txt
st-job-stats -S *.bin >> cgedf_result_$1_$2_$3_$5.txt
# st-job-stats -R *.bin >> cgedf_details_$1_$2_$3_$5.csv
# ./st.sh cgedf_$1_$2_$3_$4_$5
