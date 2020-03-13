EXP_DIR=/home/ubuntu/exp
# FT_DIR=$EXP_DIR/st
ST_DIR=$EXP_DIR/st

cd $EXP_DIR

python task_gen_vary_utilization.py $1 $2 $3

cd $ST_DIR
cd $ST_DIR/gedf
./clean.sh
setsched GSN-EDF
cd $EXP_DIR
./global_test.sh &
sleep 5
cd $ST_DIR/gedf
sleep `expr 5 + $3` | st-trace-schedule gedf_m$1_p$2_d$3_$4 &
release_ts &
wait
./st.sh gedf_m$1_p$2_d$3_$4

cd $ST_DIR/cgedf
./clean.sh
setsched CG-EDF
cd $EXP_DIR
./global_test.sh &
sleep 5
cd $ST_DIR/cgedf
sleep `expr 5 + $3` | st-trace-schedule cgedf_m$1_p$2_d$3_$4 &
release_ts &
wait
./st.sh cgedf_m$1_p$2_d$3_$4



