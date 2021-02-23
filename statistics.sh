#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

declare -i numOfArgs=$#
let numOfArgs++

LIST=FALSE
TOPN=10
ONLE=FALSE

while [ $# -eq 0 -o $numOfArgs -ne $OPTIND ]; do

  getopts "hnt:o" optKey
  if [ "$optKey" == "?" ]; then
    optKey="h"
  fi

  case $optKey in 
  	h) echo -en "\nUsuage of ${0##*/}:\n\n"
	   echo -en " -h Print this message and exit. \n\n"
	   echo -en " -n Print the Number of the logged users. \n\n"
	   echo -en " -t Print the name of the Top N users who have logged most. \n\n"
	   echo -en " -o Print the students who are online. \n\n"
	   exit 0;;
	n)
		LIST=TRUE	
		;;
	o)
		ONLE=TRUE
		;;
	t)
		PARA=${OPTARG/[0-9]*/}
		if [ "$PARA" == "" ]; then 
		  TOPN=$OPTARG
		  LIST=TRUE
		fi
		;;
  esac

done

if [ "$LIST" == "TRUE" ]; then
  # How many users have been logged so far 
  NUM=$(last -w | cut -d' ' -f1 | grep "^[0-9]" | sort | uniq | wc -l) 
  echo -en "Since $(uptime -s), in total $NUM student users have been logged.\n"
fi

if [ ! -z $TOPN -a "$LIST" == "TRUE" ]; then
  echo -en "\nThe top $TOPN students who logged most are: \n" 
  last -w | cut -d' ' -f1 | grep "^[0-9]" | sort | uniq -c | sort -nr | head -n ${TOPN} | awk -F' ' '{print $2}' | xargs -I {} grep {} ${bin}/data/names
fi

if [ "$ONLE" == "TRUE" ]; then
  NUM=$(who -w | cut -d' ' -f1 | grep "^[0-9]" | sort | uniq | wc -l)
  echo -en "In total $NUM students are online now: \n"
  who -w | cut -d' ' -f1 | grep "^[0-9]" | sort | uniq -c | sort -nr | awk -F' ' '{print $2}' | xargs -I {} grep {} ${bin}/data/names
fi
