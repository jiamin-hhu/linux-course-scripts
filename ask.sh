#!/bin/bash

bin=`readlink -f "$0"`
bin=`dirname "$bin"`
bin=`cd "$bin"; pwd`

NAMEFILE=$bin/data/names

sed -n "$(( ${RANDOM} % 183 ))p" $NAMEFILE
