#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

B=FALSE

declare -i numOfArgs=$#
let numOfArgs++

echo "First, parameter number is : $#"
while [ $# -eq 0 -o $numOfArgs -ne $OPTIND ]; do

  #echo "OPTIND is $OPTIND"

  getopts "ha:bc:" optKey
  if [ "$optKey" == "?" ]; then
    optKey="h"
  fi

  echo "optKey is $optKey"
  echo "OPTIND is $OPTIND"

  case $optKey in 
  	h) echo -en "\nUsuage of ${0##*/}:\n\n"
	   echo -en " -h Print this message and exit. \n\n"
	   echo -en " -a Define a variable named A. \n\n"
	   echo -en " -b Set an option named B. \n\n"
	   echo -en " -c Define a INT variable named C. \n\n"
	   exit 0;;
	a)
		A="${OPTARG}"
		;;
	b)
		B=TRUE
		;;
	c)
		PARA=${OPTARG/[0-9]*/}
		if [ "$PARA" == "" ]; then 
		  C=$OPTARG
		else
		  echo "Error!! Variable C should be an integer!"
		  exit -1
		fi
		;;
  esac

done

if [ "$A" != "" ]; then
  echo "Variable A is $A"
fi

if [ "$B" == "TRUE" ]; then
  echo "Option B is set true"
fi

if [ ! -z $C ]; then
  echo "Variable C is $C"
fi