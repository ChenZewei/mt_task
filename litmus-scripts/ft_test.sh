#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
TSK_FLD=$EXP_DIR/tasksets

cd $EXP_DIR

# python task_gen_vary_utilization.py $1 $2 $3 $4 $5

# chmod +x global_$1_$2_$3_$4_$5.sh
# chmod +x hc_global_$1_$2_$3_$4_$5.sh

cd $FT_DIR
cd $FT_DIR/gedf
./clean.sh
setsched GSN-EDF
cd $TSK_FLD
./global_edf_$1_$2_$3_$4_$5.sh &
sleep 2
cd $FT_DIR/gedf
sleep `expr 3 + $3 / 1000` | ft-trace-overheads gedf_$1_$2_$3_$4_$5 &
sleep 1
release_ts &
wait
./ft.sh gedf_$1_$2_$3_$4_$5

cd $FT_DIR/cgedf
./clean.sh
setsched CG-EDF
cd $TSK_FLD
./global_edf_$1_$2_$3_$4_$5.sh &
sleep 2
cd $FT_DIR/cgedf
sleep `expr 3 + $3 / 1000` | ft-trace-overheads cgedf_$1_$2_$3_$4_$5 &
sleep 1
release_ts &
wait
./ft.sh cgedf_$1_$2_$3_$4_$5

cd $FT_DIR
cd $FT_DIR/gfp
./clean.sh
setsched G-FP
cd $TSK_FLD
./global_fp_$1_$2_$3_$4_$5.sh &
sleep 2
cd $FT_DIR/gfp
sleep `expr 3 + $3 / 1000` | ft-trace-overheads gfp_$1_$2_$3_$4_$5 &
sleep 1
release_ts &
wait
./ft.sh gfp_$1_$2_$3_$4_$5

cd $FT_DIR/cgfp
./clean.sh
setsched CG-FP
cd $TSK_FLD
./global_fp_$1_$2_$3_$4_$5.sh &
sleep 2
cd $FT_DIR/cgfp
sleep `expr 3 + $3 / 1000` | ft-trace-overheads cgfp_$1_$2_$3_$4_$5 &
sleep 1
release_ts &
wait
./ft.sh cgfp_$1_$2_$3_$4_$5

# cd $FT_DIR/hc_cgedf
# ./clean.sh
# setsched CG-EDF
# cd $EXP_DIR
# ./global_test.sh &
# sleep 5
# cd $FT_DIR/hc_cgedf
# sleep `expr 5 + $3` | ft-trace-overheads hc_cgedf_m$1_p$2_d$3_$4_u$5 &
# release_ts &
# wait
# ./ft.sh hc_cgedf_m$1_p$2_d$3_$4_u$5

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


