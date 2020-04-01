#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
TSK_FLD=$EXP_DIR/tasksets

cd $EXP_DIR

cd $ST_DIR
cd $ST_DIR/gfp
./clean.sh
setsched G-FP
cd $TSK_FLD
./global_fp_$1_$2_$3_$4_$5.sh &
sleep 1
cd $ST_DIR/gfp
sleep `expr 3 + $3 / 1000` | st-trace-schedule gfp_$1_$2_$3_$4_$5 &
sleep 1
release_ts &
wait
st-job-stats -s *.bin > gfp_$1_$2_$3_$4_$5.txt
st-job-stats -S *.bin >> gfp_result_$1_$2_$3_$5.txt
# st-job-stats -R *.bin >> gfp_details_$1_$2_$3_$5.csv
# ./st.sh gfp_$1_$2_$3_$4_$5

cd $ST_DIR/cgfp
./clean.sh
setsched CG-FP
cd $TSK_FLD
./global_fp_$1_$2_$3_$4_$5.sh &
sleep 1
cd $ST_DIR/cgfp
sleep `expr 3 + $3 / 1000` | st-trace-schedule cgfp_$1_$2_$3_$4_$5 &
sleep 1
release_ts &
wait
st-job-stats -s *.bin > cgfp_$1_$2_$3_$4_$5.txt
st-job-stats -S *.bin >> cgfp_result_$1_$2_$3_$5.txt
# st-job-stats -R *.bin >> cgfp_details_$1_$2_$3_$5.csv
# ./st.sh cgfp_$1_$2_$3_$4_$5
