#!/bin/bash

bin=`readlink -f "$0"`
bin=`dirname "$bin"`
bin=`cd "$bin"; pwd`

GROUPFILE=$bin/data/groups.txt
SCOREFILE=$HOME/scores-${USER}.txt  #create a score file for each user

validateArguments() {
	gid=$1
	score=$2

	if [ "$gid" != "" ]; then
		rt=$(grep "^$gid " $GROUPFILE)
		if [ "$rt" == "" ]; then
			echo "No such group: $gid" >&2
			return 1
		fi
	fi

	if [ "$score" != "" ]; then
		if [ $score -lt 0 -o $score -gt 100 ]; then
			echo "The score must be within [0..100]" >&2
			return 1
		fi
	fi
}

GROUP_ID=""
declare -i SCORE=0 #make sure it must be an integer

declare -i numOfArgs=$#
let numOfArgs++

while [ $# -eq 0 -o $numOfArgs -ne $OPTIND ]; do

  getopts "hr:c:d:t:" optKey
  if [ "$optKey" == "?" ]; then
    optKey="h"
  fi

  case $optKey in 
  	h) echo -en "\nUsuage of ${0##*/}:\n\n"
	   echo -en " -h Print this message and exit. \n\n"
	   echo -en " -r GROUP_ID:SCORE \nRate a score to the group. \n\n"
	   echo -en " -c GROUP_ID:SCORE \nChange the score. \n\n"
	   echo -en " -d GROUP_ID \nDelete the score. \n\n"
	   echo -en " -t GROUP_ID \nlisT the score. \n\n"
	   exit 0;;
	r|c)
		GROUP_ID="${OPTARG%:*}"
		SCORE=${OPTARG#*:} #the score is assigned 0 when it is not an integer value
		if [ "$SCORE" != "${OPTARG#*:}" ]; then
			echo "The assigned score must be an integer"
		fi
		;;
	d|t)
		GROUP_ID="${OPTARG}"
		;;
  esac
done

#adapt the sed command based on the operation system 
osname=$(uname)
if [ "$osname" == "Linux" ]; then
	sedcomm="sed -i "	
elif [ "$osname" == "Darwin" ]; then
	sedcomm="sed -i '' "
else
	echo "The operation system is unknown." >&2
	exit 1
fi


# Check whether group and topic file exists.
if [ ! -f $SCOREFILE ]; then
	touch $SCOREFILE			#Create a new score file if it doesn't exist
fi
if [ ! -f $GROUPFILE ]; then
	touch $GROUPFILE			#Create a new group file if it doesn't exist
fi


rt=$(validateArguments "$GROUP_ID" "$SCORE")
if [ $? != 0 ]; then
	echo "The given arguments are not correct. "
	exit 1
fi

# -----------------------------------------------------------------------------

# rate a new score to a group
if [ "$optKey" == "r" ]; then
	#Check for repeated groups
	match=($(grep "^$GROUP_ID " $SCOREFILE | cut -d' ' -f1))
	if [ ${#match[*]} -gt 0 ]; then
		echo "The indicated group $GROUP_ID has already been rated."
		exit 1
	fi

	echo "$GROUP_ID $SCORE" >> $SCOREFILE
	echo "The group $GROUP_ID is rated as $SCORE"
fi

# change the score
if [ "$optKey" == "c" ]; then
	#Check for repeated groups
	match=($(grep "^$GROUP_ID " $SCOREFILE | cut -d' ' -f1))
	if [ ${#match[*]} -eq 0 ]; then
		echo "The indicated group $GROUP_ID has not been rated."
		exit 1
	elif [ ${#match[*]} -gt 1 ]; then
		echo "The indicated group $GROUP_ID has been rated more than once."
		exit 1
	fi

	matchline=$(grep "^$GROUP_ID " $SCOREFILE)
	newline="$GROUP_ID $SCORE"

	eval $sedcomm "'s/${matchline}/${newline}/'" $SCOREFILE
	echo "The score of group $GROUP_ID is changed to $SCORE"
fi

# Delete a score
if [ "$optKey" == "d" ]; then
	match=($(grep "^$GROUP_ID " $SCOREFILE | cut -d' ' -f1))
	if [ ${#match[*]} -eq 0 ]; then
		echo "The indicated group $GROUP_ID has not been rated."
		exit 1
	fi

	eval $sedcomm "/^$GROUP_ID/d" $SCOREFILE
	echo "The score for group $GROUP_ID is deleted."
fi

# List the selected topic
if [ "$optKey" == "t" ]; then
	match=($(grep "^$GROUP_ID " $SCOREFILE | cut -d' ' -f1))
	if [ ${#match[*]} -eq 0 ]; then
		echo "The indicated group $GROUP_ID has not been rated."
		exit 1
	fi

	matchline=$(grep "^$GROUP_ID " $SCOREFILE)
	declare -i score=${matchline#* }
	echo "The score for group $GROUP_ID is ${score}."
fi

