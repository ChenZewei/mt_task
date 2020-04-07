#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
TSK_FLD=$EXP_DIR/tasksets

duration=$1
total_duration=$2

cd $EXP_DIR
./clean_all.sh

cd $FT_DIR/gedf
./clean.sh
setsched GSN-EDF
sleep `expr 10  + $total_duration` | ft-trace-overheads gedf &
cd $TSK_FLD
for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset` &
sleep 1
release_ts &
sleep $duration
done
wait
cd $FT_DIR/gedf
./ft.sh gedf

cd $FT_DIR/cgedf
./clean.sh
setsched CG-EDF
sleep `expr 10  + $total_duration` | ft-trace-overheads cgedf &
cd $TSK_FLD
for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset` &
sleep 1
release_ts &
sleep $duration
done
wait
cd $FT_DIR/cgedf
./ft.sh cgedf

cd $FT_DIR/gfp
./clean.sh
setsched G-FP
sleep `expr 10  + $total_duration` | ft-trace-overheads gfp &
cd $TSK_FLD
for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset` &
sleep 1
release_ts &
sleep $duration
done
wait
cd $FT_DIR/gfp
./ft.sh gfp

cd $FT_DIR
cd $FT_DIR/cgfp
./clean.sh
setsched CG-FP
sleep `expr 10  + $total_duration` | ft-trace-overheads cgfp &
cd $TSK_FLD
for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset` &
sleep 1
release_ts &
sleep $duration
done
wait
cd $FT_DIR/cgfp
./ft.sh cgfp



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



