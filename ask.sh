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

sed -n "$(( ${RANDOM} % ${LNUM} ))p" $NAMEFILE
