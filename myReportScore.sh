#!/bin/bash

bin=`readlink -f "$0"`
bin=`dirname "$bin"`
#bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

#SCOREFILE=$bin/data/scores.txt
SCOREFILE=$bin/Final_scores
USERID=${USER}

declare -i numOfArgs=$#
let numOfArgs++

while [ $# -eq 0 -o $numOfArgs -ne $OPTIND ]; do

  getopts "th:s:" optKey
  if [ "$optKey" == "?" ]; then
    optKey="h"
  fi

  case $optKey in 
  	h) echo -en "\nUsuage of ${0##*/}:\n\n"
	   echo -en " -h Print this message and exit. \n\n"
	   echo -en " -t lisT ${USER}'s report score. \n\n"
	   echo -en " -s Search score while the user is jiamin only. \n\n"
	   exit 0;;
	s) USERID="${OPTARG}"
	   if [ ${USER} != "jiamin" ]; then
	     echo -en "You are not the super user!\n\n"
	     exit 2
	   fi
	   ;;
  esac
done

TITLES=(`head -n 1 "${SCOREFILE}"`)
FNUM=${#TITLES[*]}
SCORELINE=(`grep ${USERID} "${SCOREFILE}"`)

if [ ${#SCORELINE[*]} == 0 ]; then
	echo "There is no such user."
	exit -1
elif [ ${SCORELINE[3]} == "#N/A" ]; then
	echo "Your report is not yet commited."
	exit -1
else
	for i in "${!TITLES[@]}"; do
		echo -e "${TITLES[$i]}: \t ${SCORELINE[$i]}"
	done
fi

