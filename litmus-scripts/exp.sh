
if [ "$#" -eq "4" ];
then
  m=$1
  p=$2
  d=$3
  iteration=$4
else
  m=8
  p=4
  d=10
  iteration=1
fi

for((i=0;i<$iteration;i++));
do
  #echo $i
  ./test.sh $m $p $d $i
done
