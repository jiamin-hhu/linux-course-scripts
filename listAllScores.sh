#/bin/bash

cat ./data/names| while read line 
do
  val=($line)
  id=${val[0]}
  name=${val[1]}
  echo "------------------------------------"
  echo "$name "
  ./myReportScore.sh -s $id | sed -n '2p'
  ./myReportScore.sh -s $id | sed -n '12p'
  echo "------------------------------------"
done
