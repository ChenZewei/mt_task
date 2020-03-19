#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

cd $EXP_DIR

python task_gen_vary_utilization.py $1 $2 $3 $5

cd $FT_DIR
cd $FT_DIR/gedf
./clean.sh
setsched GSN-EDF
cd $EXP_DIR
./global_test.sh &
sleep 5
cd $FT_DIR/gedf
sleep `expr 5 + $3` | ft-trace-overheads gedf_m$1_p$2_d$3_$4_u$5 &
release_ts &
wait
./ft.sh gedf_m$1_p$2_d$3_$4_u$5

cd $FT_DIR/cgedf
./clean.sh
setsched CG-EDF
cd $EXP_DIR
./global_test.sh &
sleep 5
cd $FT_DIR/cgedf
sleep `expr 5 + $3` | ft-trace-overheads cgedf_m$1_p$2_d$3_$4_u$5 &
release_ts &
wait
./ft.sh cgedf_m$1_p$2_d$3_$4_u$5

cd $FT_DIR/cgedf
./clean.sh
setsched CG-EDF
cd $EXP_DIR
./global_test.sh &
sleep 5
cd $FT_DIR/cgedf
sleep `expr 5 + $3` | ft-trace-overheads hc_cgedf_m$1_p$2_d$3_$4_u$5 &
release_ts &
wait
./ft.sh hc_cgedf_m$1_p$2_d$3_$4_u$5

# cd $FT_DIR/pedf
# ./clean.sh
# setsched PSN-EDF
# cd $EXP_DIR
# ./partitioned_test.sh &
# sleep 5
# cd $FT_DIR/pedf
# sleep `expr 5 + $3` | ft-trace-overheads pedf_m$1_p$2_d$3_$4_u$5 &
# release_ts &
# wait
# ./ft.sh pedf_m$1_p$2_d$3_$4_u$5


