#!/bin/bash
EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

if [ "$#" -eq "5" ];
then
  m=$1
  p=$2
  d=$3
  iteration=$4
  norm_u=$5
else
  m=8
  p=4
  d=10
  iteration=1
  norm_u=1
fi

for((i=0;i<$iteration;i++));
do
  #echo $i
  # python task_gen_vary_utilization.py $m $p $d $norm_u
  # ./st_test.sh $m $p $d $i $norm_u
  # ./ft_test.sh $m $p $d $i $norm_u
  ./scheduling_test.sh $m $p $d $i $norm_u
done

cd $ST_DIR/gedf
s=`grep "1" result.txt| wc -l`
echo "scale=3;$s/$iteration" | bc >> gedf_ratio_m$1_p$2_d$3.txt
rm result.txt

cd $ST_DIR/cgedf
s=`grep "1" result.txt| wc -l`
echo "scale=3;$s/$iteration" | bc >> cgedf_ratio_m$1_p$2_d$3.txt
rm result.txt

cd $ST_DIR/hc_cgedf
s=`grep "1" result.txt| wc -l`
echo "scale=3;$s/$iteration" | bc >> hc_cgedf_ratio_m$1_p$2_d$3.txt
rm result.txt
