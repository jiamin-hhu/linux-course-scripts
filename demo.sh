pwd

if [ -f ../env.sh ]; then 
  echo "true" 
else 
  echo "false"
fi

#source ../env.sh
source env.sh
## 如果是 source 的话，由于 env.sh 也是在$PATH 中的，因此也能找到
