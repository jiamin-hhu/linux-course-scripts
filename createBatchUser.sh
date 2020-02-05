#!/bin/bash

##################################################
## !!!! Must use cat -A to check whether the id list 
## contains invisible characthers, like ^M
## We can use :set fileformat=unix command to remove them in vi. 
##################################################


if [ "$1" == "" ]; then
  echo "Error! I need a student id list file "
  exit -1
fi 

if [ ! -f $1 ]; then
  echo "Error! $1 is a invalid filename"
  exit -1
fi

listpath=$1
listname=${listpath##*/}

count=0

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

