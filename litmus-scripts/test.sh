#!/bin/bash
EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

cd $ST_DIR/gedf
./gedf_st.sh 8 8 10000 10

cd $ST_DIR/cgedf
./cgedf_st.sh 8 8 10000 10

cd $ST_DIR/gfp
./gfp_st.sh 8 8 10000 10

cd $ST_DIR/cgfp
./cgfp_st.sh 8 8 10000 10