#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

cd $EXP_DIR

# python task_gen_vary_utilization.py $1 $2 $3 $5
gap=`expr 2 + $3 / 1000`

cd $ST_DIR
cd $ST_DIR/gedf
./clean.sh
setsched GSN-EDF
cd $EXP_DIR/st/tasksets
./global_${1}_${2}_${3}_${4}_${5}.sh  &
sleep 2
cd $ST_DIR/gedf
sleep $gap | st-trace-schedule gedf_m$1_p$2_d$3_u$5 &
release_ts &
wait
# ./st.sh gedf_m$1_p$2_d$3_i$4_u$5
st-job-stats -S *.bin >> result_m$1_p$2_d$3_u$5.txt

cd $ST_DIR/cgedf
./clean.sh
setsched CG-EDF
cd $EXP_DIR/st/tasksets
./global_${1}_${2}_${3}_${4}_${5}.sh &
sleep 2
cd $ST_DIR/cgedf
sleep $gap | st-trace-schedule cgedf_m$1_p$2_d$3_u$5 &
release_ts &
wait
# ./st.sh cgedf_m$1_p$2_d$3_i$4_u$5
st-job-stats -S *.bin >> result_m$1_p$2_d$3_u$5.txt

# cd $ST_DIR/hc_cgedf
# ./clean.sh
# setsched CG-EDF
# cd $EXP_DIR/st/tasksets
# ./hc_global_${1}_${2}_${3}_${4}_${5}.sh &
# sleep 2
# cd $ST_DIR/hc_cgedf
# sleep $gap | st-trace-schedule hc_cgedf_m$1_p$2_d$3_u$5 &
# release_ts &
# wait
# # ./st.sh hc_cgedf_m$1_p$2_d$3_i$4_u$5
# st-job-stats -S *.bin >> result_m$1_p$2_d$3_u$5.txt

