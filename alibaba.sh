#!/bin/bash
echo -n "Give me a magic word: "
read mgw
while [ "$mgw" != "alibaba" ]; do
  echo -n "Opps, try again :"
  read mgw
  if [ "$mgw" == "" ]; then
    echo -e "\nGood Game"
    exit 1
  fi 
done 

echo "Congratulations! "
exit 0

