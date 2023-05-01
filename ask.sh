#!/bin/bash
bin=`readlink -f "$0"`
bin=`dirname "$bin"`
bin=`cd "$bin"; pwd`

if [ "" != "$1" ] && [ -f $1 ]; then
  NAMEFILE=$1
else
  NAMEFILE=$bin/data/names
fi

LNUM=$(wc -l $NAMEFILE | cut -d' ' -f1)


for i in {1..20}; do
  winner=$(sed -n "$(( ${RANDOM} % ${LNUM} ))p" $NAMEFILE 2>/dev/null)
  winner=$(echo $winner | cut -d' ' -f2) 
  printf "\r"
  printf "the winner is: %s\r" $winner
  sleep 0.2
done
echo 
