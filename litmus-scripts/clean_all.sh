EXP_DIR=/home/ubuntu/exp
FT_DIR=$EXP_DIR/ft
ST_DIR=$EXP_DIR/st

cd $ST_DIR

for dir in `ls`
do
  if [ -d $dir ]; then
    echo "enter $dir"
    cd $dir
    rm *.txt *.bin *.float32 *.sf32 *.log *.csv *.pdf
    echo "exit $dir"
    cd ../
  fi
done
#rm *.bin *.float32 *.sf32 *.log *.csv *.pdf
