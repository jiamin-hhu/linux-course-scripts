#!/bin/bash

bin=`readlink -f "$0"`
bin=`dirname "$bin"`
bin=`cd "$bin"; pwd`

GROUPFILE=$bin/data/groups.txt
STUDENTFILE=$bin/student_ids.txt

validateArguments() {
	gid=$1
	sid=$2

	if [ "$gid" != "" ]; then
		rt=$(grep "^$gid " $GROUPFILE)
		if [ "$rt" == "" ]; then
			echo "No such group: $gid" >&2
			return 1
		fi
	fi

	if [ "$sid" != "" ]; then
		rt=$(grep "$sid" $STUDENTFILE)
		if [ "$rt" == "" ]; then
			echo "No such student: $sid" >&2
			return 1
		fi
	fi
}


GROUP_ID=""
STUDENT_ID=""
LEADER_ID=""

declare -i numOfArgs=$#
let numOfArgs++

while [ $# -eq 0 -o $numOfArgs -ne $OPTIND ]; do

  getopts "hc:a:d:e:t:f:p" optKey
  if [ "$optKey" == "?" ]; then
    optKey="h"
  fi

  case $optKey in 
  	h) echo -en "\nUsuage of ${0##*/}:\n\n"
	   echo -en " -h Print this message and exit. \n\n"
	   echo -en " -c STUDENT_ID \nCreate a new group, while the leader is the given student id. \n\n"
	   echo -en " -e GROUP_ID \nEliminate a group, while the current user is the leader. \n\n"
	   echo -en " -a GROUP_ID:STUDENT_ID \nAdd a new member to a group. \n\n"
	   echo -en " -d GROUP_ID:STUDENT_ID \nDelete a member from a group. \n\n"
	   echo -en " -t GROUP_ID \nlisT all members in the group. \n\n"
	   echo -en " -f STUDENT_ID \nFind the group where the given student is enlisted. \n\n"
	   echo -en " -p \nPrint the statistics of grouped students. \n\n "
	   exit 0;;
	c)
		STUDENT_ID="${OPTARG}"
		LEADER_ID=$STUDENT_ID
		;;
	e)
		GROUP_ID="${OPTARG}"
		;;
	a)
		GROUP_ID="${OPTARG%:*}"
		STUDENT_ID="${OPTARG#*:}"
		;;
	d)
		GROUP_ID="${OPTARG%:*}"
		STUDENT_ID="${OPTARG#*:}"
		;;
	t)
		GROUP_ID="${OPTARG}"
		;;
	f)
		STUDENT_ID="${OPTARG}"
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


# Check whether student and group file exists.
if [ ! -f $STUDENTFILE ]; then
	echo "The student id list file doesn't exist."
	exit 1
fi
if [ ! -f $GROUPFILE ]; then
	touch $GROUPFILE			#Create a new group file if it doesn't exist
fi

rt=$(validateArguments "$GROUP_ID" "$STUDENT_ID")
if [ $? != 0 ]; then
	echo "The given arguments are not correct. "
	exit 1
fi


# ------------------------------------------------------------------------------------------

# Create a new group
if [ "$optKey" == "c" ]; then
	match=($(grep "$LEADER_ID" $GROUPFILE | cut -d' ' -f1))
	group_num=${#match[*]}
	if [ $group_num -gt 0 ]; then
		echo "The given leader $LEADER_ID is enlisted in another group."
		exit 1
	fi

	lastgroupid=$(tail -n 1 $GROUPFILE | cut -d' ' -f 1)
	if [ lastgroupid == "" ]; then
		GROUP_ID=1
	else
		GROUP_ID=$((lastgroupid+1))
	fi
	echo "$GROUP_ID $LEADER_ID" >> $GROUPFILE
	echo "The new group id is: $GROUP_ID"
fi

# Eliminate a group
if [ "$optKey" == "e" ]; then
	groupinfo=$(grep "^$GROUP_ID " $GROUPFILE)
	LEADER_ID=$(echo $groupinfo | cut -d' ' -f 2)
	if [ "$LEADER_ID" != "$USER" -a "$USER" != "jiamin" ]; then
		echo "The group can only be deleted by the leader $LEADER_ID." >&2
		exit 2
	else
		eval $sedcomm "/^$GROUP_ID/d" $GROUPFILE
		echo "The group $GROUP_ID is deleted"
	fi
fi

# Add a new user to an existing group
if [ "$optKey" == "a" ]; then
	match=($(grep "$STUDENT_ID" $GROUPFILE | cut -d' ' -f1))
	group_num=${#match[*]}
	if [ $group_num -gt 0 ]; then
		echo "The student $STUDENT_ID has already been enlisted in other groups: ${match[*]}"
		exit 1
	fi

	matchline=$(grep "^$GROUP_ID " $GROUPFILE)
	members=(${matchline#* })
	if [ ${#members[*]} -ge 4 ]; then
		echo "A group can has maximum 4 members."
		exit 1
	fi

	newline=$(echo "$matchline $STUDENT_ID")
	eval $sedcomm "'s/${matchline}/${newline}/'" $GROUPFILE

	echo "The group $GROUP_ID now has members: ${newline#* }"
fi

# Remove a user from an existing group
if [ "$optKey" == "d" ]; then
	match=($(grep "$STUDENT_ID" $GROUPFILE | cut -d' ' -f1))
	group_num=${#match[*]}
	if [ $group_num -ne 1 ]; then
		echo "The student $STUDENT_ID either doesn't exist or enlisted in several groups"
		exit 1
	fi

	matchline=$(grep "^$GROUP_ID " $GROUPFILE)
	newline=${matchline/${STUDENT_ID}/""}
	eval $sedcomm "'s/${matchline}/${newline}/'" $GROUPFILE

	echo "The group $GROUP_ID now has the members: ${newline#* }"
fi

# List the group information
if [ "$optKey" == "t" ]; then
	grep "^$GROUP_ID " $GROUPFILE
fi

# Find where the student is
if [ "$optKey" == "f" ]; then
	grep "$STUDENT_ID " $GROUPFILE
fi

# Print the statistics of the grouped students
if [ "$optKey" == "p" ]; then
	NUM_GROUPS=`cat $GROUPFILE | grep -v "^$" | wc -l`
	NUM_GROUPED=`cat $GROUPFILE | awk '{print $2,$3,$4,$5,$6}' | tr ' ' '\n' | grep -v "^$" | wc -l`
	echo -en "\nSo far there are $NUM_GROUPED students set in total $NUM_GROUPS groups.\n\n"
fi

exit 0
