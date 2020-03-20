#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

cd $EXP_DIR

python task_gen_vary_utilization.py $1 $2 $3 $5

gap=`expr 5 + $3 / 1000`
echo $gap

cd $ST_DIR
cd $ST_DIR/gedf
./clean.sh
setsched GSN-EDF
cd $EXP_DIR
./global_test.sh &
sleep 5
cd $ST_DIR/gedf
sleep $gap | st-trace-schedule gedf_m$1_p$2_d$3_$4_u$5 &
release_ts &
wait
./st.sh gedf_m$1_p$2_d$3_$4_u$5
st-job-stats -S *.bin >> result.txt

cd $ST_DIR/cgedf
./clean.sh
setsched CG-EDF
cd $EXP_DIR
./global_test.sh &
sleep 5
cd $ST_DIR/cgedf
sleep $gap | st-trace-schedule cgedf_m$1_p$2_d$3_$4_u$5 &
release_ts &
wait
./st.sh cgedf_m$1_p$2_d$3_$4_u$5
st-job-stats -S *.bin >> result.txt

cd $ST_DIR/hc_cgedf
./clean.sh
setsched CG-EDF
cd $EXP_DIR
./global_test_hc.sh &
sleep 5
cd $ST_DIR/hc_cgedf
sleep $gap | st-trace-schedule hc_cgedf_m$1_p$2_d$3_$4_u$5 &
release_ts &
wait
./st.sh hc_cgedf_m$1_p$2_d$3_$4_u$5
st-job-stats -S *.bin >> result.txt

