#!/bin/bash

EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st
TSK_FLD=$EXP_DIR/tasksets

duration=$1
total_duration=$2

cd $EXP_DIR
./clean_all.sh

cd $ST_DIR/gedf
./clean.sh
setsched GSN-EDF
sleep `expr 10  + $total_duration` | st-trace-schedule gedf &
cd $TSK_FLD
for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset` &
sleep 1
release_ts &
sleep $duration
done
wait
cd $ST_DIR/gedf
./st.sh gedf

cd $ST_DIR/cgedf
./clean.sh
setsched CG-EDF
sleep `expr 10  + $total_duration` | st-trace-schedule cgedf &
cd $TSK_FLD
for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset` &
sleep 1
release_ts &
sleep $duration
done
wait
cd $ST_DIR/cgedf
./st.sh cgedf

cd $ST_DIR/gfp
./clean.sh
setsched G-FP
sleep `expr 10  + $total_duration` | st-trace-schedule gfp &
cd $TSK_FLD
for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset` &
sleep 1
release_ts &
sleep $duration
done
wait
cd $ST_DIR/gfp
./st.sh gfp

cd $ST_DIR/cgfp
./clean.sh
setsched CG-FP
sleep `expr 10  + $total_duration` | st-trace-schedule cgfp &
cd $TSK_FLD
for tskset in `ls -l *.sh | awk '{print $9}'`
do
`./$tskset` &
sleep 1
release_ts &
sleep $duration
done
wait
cd $ST_DIR/cgfp
./st.sh cgfp



# cd $FT_DIR
# cd $FT_DIR/gedf
# ./clean.sh
# setsched GSN-EDF
# cd $TSK_FLD
# ./global_edf_$1_$2_$3_$4_$5.sh &
# sleep 2
# cd $FT_DIR/gedf
# sleep `expr 3 + $3 / 1000` | st-trace-schedule gedf_$1_$2_$3_$4_$5 &
# sleep 1
# release_ts &
# wait
# ./st.sh gedf_$1_$2_$3_$4_$5



