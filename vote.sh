#!/bin/bash

bin=`readlink -f "$0"`
bin=`dirname "$bin"`
bin=`cd "$bin"; pwd`

GROUPFILE=$bin/data/groups.txt
TOPICFILE=$bin/data/selection.txt

validateArguments() {
	gid=$1
	tid=$2

	if [ "$gid" != "" ]; then
		rt=$(grep "^$gid " $GROUPFILE)
		if [ "$rt" == "" ]; then
			echo "No such group: $gid" >&2
			return 1
		fi
	fi

	if [ "$tid" != "" ]; then
		if [ "${tid/[0-9]*/}" != "" ]; then
			echo "The topic id must be an integer" >&2
			return 1
		elif [ $tid -lt 1 -o $tid -gt 10 ]; then
			echo "The topic id must be within [1..10]" >&2
			return 1
		fi
	fi
}

TOPICS=( '5 大 Unix/Linux 谣言粉碎机' 
	'使用 Windows 能够带来的 5 大软件开发优势' 
	'我常用的 5 大收费（盗版）软件 vs. 它的开源替代品（alternative）' 
 	'寻找 IT 工作时，最需要掌握的 5 大技能' 
	'为了吃鸡顺利，我的5000元神机配置清单和理由' 
	'我最习惯的编程语言' 
	'我最顺手的软件开发工具 / 环境' 
	'我最推荐的计算机类专业书籍' 
	'我最常去的技术学习和讨论平台' 
	'自选命题'
	)

printAllTopics() {
	echo "所有可选选题包括：" >&2
	declare -i num=1
	for topic in "${TOPICS[@]}"; do
		echo -e "$num\t$topic" >&2
		let num++
	done
}

printOneTopic() {
	selected=$1
	echo "${selected} : ${TOPICS[$((${selected} - 1))]}"
}

validateSelection() {
	tid=$1

	#Each topic cannot be selected for more than 5 times
	match=($(grep " ${tid}$" $TOPICFILE | cut -d' ' -f2))
	if [ ${#match[*]} -ge 5 ]; then
		echo "The indicated topic $tid has already been selected more than 5 times." >&2
		return 1
	fi
}

isLeader() {
  gid=$1
  leader=$(grep "^${gid} " $GROUPFILE | cut -d' ' -f2)
  if [ $USER != ${leader} ]; then
    echo "the current user is not the group leader" >&2
    return 1
  fi
  return 0  
}

GROUP_ID=""
TOPIC_ID=""

declare -i numOfArgs=$#
let numOfArgs++

while [ $# -eq 0 -o $numOfArgs -ne $OPTIND ]; do

  getopts "hs:c:d:t:" optKey
  if [ "$optKey" == "?" ]; then
    optKey="h"
  fi

  case $optKey in 
  	h) echo -en "\nUsuage of ${0##*/}:\n\n"
	   echo -en " -h Print this message and exit. \n\n"
	   echo -en " -s GROUP_ID:TOPIC_ID \nSelect a new topic. \n\n"
	   echo -en " -c GROUP_ID:TOPIC_ID \nChange a topic. \n\n"
	   echo -en " -d GROUP_ID \nDelete a selection. \n\n"
	   echo -en " -t GROUP_ID \nlisT a selection. \n\n"
	   $(printAllTopics)
	   exit 0;;
	s)
		GROUP_ID="${OPTARG%:*}"
		TOPIC_ID="${OPTARG#*:}"
		;;
	c)
		GROUP_ID="${OPTARG%:*}"
		TOPIC_ID="${OPTARG#*:}"
		;;
	d)
		GROUP_ID="${OPTARG}"
		;;
	t)
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
if [ ! -f $TOPICFILE ]; then
	touch $TOPICFILE			#Create a new selection file if it doesn't exist
fi
if [ ! -f $GROUPFILE ]; then
	touch $GROUPFILE			#Create a new group file if it doesn't exist
fi


rt=$(validateArguments "$GROUP_ID" "$TOPIC_ID")
if [ $? != 0 ]; then
	echo "the given arguments are not correct. "
	exit 1
fi

# -----------------------------------------------------------------------------

# Select a new topic
if [ "$optKey" == "s" ]; then

        $(isLeader $GROUP_ID)
        if [ $? -ne 0 ]; then
          echo "Only the group leader is able to select a topic."
          exit 1
        fi
	
	#Check for repeated groups
	match=($(grep "^$GROUP_ID " $TOPICFILE | cut -d' ' -f1))
	if [ ${#match[*]} -gt 0 ]; then
		echo "The indicated group $GROUP_ID has already selected a topic."
		exit 1
	fi

	$(validateSelection $TOPIC_ID)
	if [ $? -ne 0 ]; then
		exit 1
	fi

	echo "$GROUP_ID $TOPIC_ID" >> $TOPICFILE
	echo "Select for group $GROUP_ID a new topic $(printOneTopic $TOPIC_ID)"
fi

# Change a topic
if [ "$optKey" == "c" ]; then
        $(isLeader $GROUP_ID)
        if [ $? -ne 0 ]; then
          echo "Only the group leader is able to change the selected topic."
          exit 1
        fi

	match=($(grep "^$GROUP_ID " $TOPICFILE | cut -d' ' -f1))
	if [ ${#match[*]} -eq 0 ]; then
		echo "The indicated group $GROUP_ID has no selected topic yet."
		exit 1
	elif [ ${#match[*]} -gt 1 ]; then
		echo "The indicated group $GROUP_ID has more than one selection."
		exit
	fi

	$(validateSelection $TOPIC_ID)
	if [ $? -ne 0 ]; then
		exit 1
	fi

	matchline=$(grep "^$GROUP_ID " $TOPICFILE)
	newline="$GROUP_ID $TOPIC_ID"

	eval $sedcomm "'s/${matchline}/${newline}/'" $TOPICFILE
	echo "The selection for group $GROUP_ID is changed to $(printOneTopic $TOPIC_ID)"
fi

# Delete a selection
if [ "$optKey" == "d" ]; then

        $(isLeader $GROUP_ID)
        if [ $? -ne 0 ]; then
          echo "Only the group leader is able to delete the selected topic."
          exit 1
        fi

	match=($(grep "^$GROUP_ID " $TOPICFILE | cut -d' ' -f1))
	if [ ${#match[*]} -eq 0 ]; then
		echo "The indicated group $GROUP_ID has no selected topic yet."
		exit 1
	fi

	eval $sedcomm "/^$GROUP_ID/d" $TOPICFILE
	echo "The selection for group $GROUP_ID is deleted."
fi

# List the selected topic
if [ "$optKey" == "t" ]; then
	match=($(grep "^$GROUP_ID " $TOPICFILE | cut -d' ' -f1))
	if [ ${#match[*]} -eq 0 ]; then
		echo "The indicated group $GROUP_ID has no selected topic yet."
		exit 1
	fi

	matchline=$(grep "^$GROUP_ID " $TOPICFILE)
	declare -i selected=${matchline#* }
	echo "For group $GROUP_ID, the selected topic id is $(printOneTopic $selected)"
fi

exit 0