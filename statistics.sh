#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

declare -i numOfArgs=$#
let numOfArgs++

LIST=FALSE
TOPN=10

while [ $# -eq 0 -o $numOfArgs -ne $OPTIND ]; do

  getopts "hnt:" optKey
  if [ "$optKey" == "?" ]; then
    optKey="h"
  fi

  case $optKey in 
  	h) echo -en "\nUsuage of ${0##*/}:\n\n"
	   echo -en " -h Print this message and exit. \n\n"
	   echo -en " -n Print the Number of the logged users. \n\n"
	   echo -en " -t Print the name of the Top N users who have logged most. \n\n"
	   exit 0;;
	n)
		LIST=TRUE	
		;;
	t)
		PARA=${OPTARG/[0-9]*/}
		if [ "$PARA" == "" ]; then 
		  TOPN=$OPTARG
		fi
		;;
  esac

done

if [ "$LIST" == "TRUE" ]; then
  # How many users have been logged so far 
  NUM=$(last -w | cut -d' ' -f1 | grep "^[0-9]" | sort | uniq | wc -l) 
  echo -en "Since $(uptime -s), in total $NUM student users have been logged.\n"
fi

if [ ! -z $TOPN ]; then
  echo -en "\nThe top $TOPN students who logged most are: \n" 
  last -w | cut -d' ' -f1 | grep "^[0-9]" | sort | uniq -c | sort -nr | head -n ${TOPN} | awk -F' ' '{print $2}' | xargs -I {} grep {} ${bin}/names
fi
