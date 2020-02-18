for dir in `ls`
do
  if [ -d $dir ]; then
    echo "enter $dir"
    cd $dir
    rm *.bin *.float32 *.sf32 *.log *.csv *.pdf
    echo "exit $dir"
    cd ../
  fi
done
#rm *.bin *.float32 *.sf32 *.log *.csv *.pdf
