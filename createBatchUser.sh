#!/bin/bash

##################################################
## !!!! Must use cat -A to check whether the id list 
## contains invisible characthers, like ^M
## We can use :set fileformat=unix command to remove them in vi. 
##################################################

declare -i numOfArgs=$#
let numOfArgs++
FILENAME=""
OP=""

while [ $# -eq 0 -o $numOfArgs -ne $OPTIND ]; do
  getopts "ha:d:" optKey
  if [ "$optKey" == "?" ]; then
    optKey="h"
  fi

  case $optKey in
        h) echo -en "\nUsuage of ${0##*/}:\n\n"
           echo -en " -h Print this message and exit. \n\n"
           echo -en " -a Add users listed in the given file. \n\n"
           echo -en " -d Delete users listed in the given file. \n\n"
           exit 0;;
        a)
                OP="add"
                FILENAME="${OPTARG}"
                ;;
        d)
                OP="del"
                FILENAME="${OPTARG}"
                ;;
  esac
done

if [ "$FILENAME" == "" ]; then
  echo "Error! I need a student id list file "
  exit -1
fi 

if [ ! -f $FILENAME ]; then
  echo "Error! $FILENAME is a invalid filename"
  exit -1
fi

listpath=$FILENAME
listname=${listpath##*/}

count=0

if [ "$OP" == "add" ]; then
  for id in $(cat $listpath); do
    un=$id 
  
    # Indicate the user's group, shell, and create its home directory
    sudo useradd -d /home/$un -m -g students -s /bin/bash $un
  
    echo $un:$un | sudo chpasswd
  
    sudo chage -d 0 $un
    sudo cp $listpath /home/$un
    sudo chown $un:students /home/$un/$listname
    sudo chmod 600 /home/$un/$listname 
    echo "Create user $un successfully!"
    ((count++))
  done
  
  echo "In total create $count users"
elif [ "OP" == "del" ]; then
  for id in $(cat $listpath); do
    sudo userdel -f -r $id
    ((count++))
  done
  
  echo "In total delete $count users"
else
  echo "Cannot recognize the operation $OP."
  exit -2
fi
