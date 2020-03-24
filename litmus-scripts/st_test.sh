#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
TSK_FLD=$EXP_DIR/st/tasksets

cd $EXP_DIR

# python task_gen_vary_utilization.py $1 $2 $3 $4 $5
# python task_gen_vary_utilization_random_period.py $1 $2 $3 $4 $5

# chmod +x global_$1_$2_$3_$4_$5.sh
# chmod +x hc_global_$1_$2_$3_$4_$5.sh

cd $ST_DIR
cd $ST_DIR/gedf
./clean.sh
setsched GSN-EDF
cd $TSK_FLD
./global_$1_$2_$3_$4_$5.sh &
sleep 5
cd $ST_DIR/gedf
sleep `expr 5 + $3 / 1000` | st-trace-schedule gedf_$1_$2_$3_$4_$5 &
release_ts &
wait
st-job-states -S gedf_$1_$2_$3_$4_$5
# ./st.sh gedf_$1_$2_$3_$4_$5

cd $ST_DIR/cgedf
./clean.sh
setsched CG-EDF
cd $TSK_FLD
./global_$1_$2_$3_$4_$5.sh &
sleep 5
cd $ST_DIR/cgedf
sleep `expr 5 + $3 / 1000` | st-trace-schedule cgedf_$1_$2_$3_$4_$5 &
release_ts &
wait
st-job-states -S cgedf_$1_$2_$3_$4_$5
# ./st.sh cgedf_$1_$2_$3_$4_$5

cd $ST_DIR
cd $ST_DIR/gfp
./clean.sh
setsched G-FP
cd $TSK_FLD
./global_$1_$2_$3_$4_$5.sh &
sleep 5
cd $ST_DIR/gfp
sleep `expr 5 + $3 / 1000` | st-trace-schedule gfp_$1_$2_$3_$4_$5 &
release_ts &
wait
st-job-states -S gfp_$1_$2_$3_$4_$5
# ./st.sh gfp_$1_$2_$3_$4_$5

cd $ST_DIR/cgfp
./clean.sh
setsched CG-FP
cd $TSK_FLD
./global_$1_$2_$3_$4_$5.sh &
sleep 5
cd $ST_DIR/cgfp
sleep `expr 5 + $3 / 1000` | st-trace-schedule cgfp_$1_$2_$3_$4_$5 &
release_ts &
wait
st-job-states -S cgfp_$1_$2_$3_$4_$5
# ./st.sh cgfp_$1_$2_$3_$4_$5

# cd $ST_DIR/hc_cgedf
# ./clean.sh
# setsched CG-EDF
# cd $EXP_DIR
# ./hc_global_$1_$2_$3_$4_$5.sh &
# sleep 5
# cd $ST_DIR/hc_cgedf
# sleep `expr 5 + $3 / 1000` | st-trace-schedule hc_cgedf_m$1_p$2_d$3_$4_u$5 &
# release_ts &
# wait
# ./st.sh hc_cgedf_m$1_p$2_d$3_$4_u$5

