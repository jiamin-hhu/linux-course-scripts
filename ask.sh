#!/bin/bash

bin=`readlink -f "$0"`
bin=`dirname "$bin"`
bin=`cd "$bin"; pwd`

NAMEFILE=$bin/data/names
LNUM=$(wc -l $NAMEFILE | cut -d' ' -f1)

sed -n "$(( ${RANDOM} % ${LNUM} ))p" $NAMEFILE
