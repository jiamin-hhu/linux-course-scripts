#!/bin/bash

TOPICS=( '掌握Linux，在 ** 岗位有多重要'
        '掌握Linux，在研究生阶段有多重要'
	'手机 OS 和 桌面端 OS 有多不同'
	'鸿蒙 OS 和 Linux 有多不同'
        '如何利用 Linux 搭建 ** 的学习平台'
        '利用Linux， 我能够 ** 了'
        '如何搭上 AIGC 这班快车'
        '在软件行业怎么做，才能不被人工智能替代'
        '未来十年，这个 ** 技术我觉得行'
        '自选命题'
        )

cat data/groups.txt | while read line; do
  gpID=${line%% *}
  stIDs=(${line#* })
  declare -i cnt=0
  res="小组${gpID}: "
  for id in ${stIDs[@]}; do
    name=$(grep $id data/names | cut -d' ' -f2)
    if [ $cnt -eq 0 ]; then
      res="${res}${name}(组长) "
    else
      res="${res}${name} "
    fi
    ((cnt++))
  done
  echo $res
  
  slt=$(grep "^${gpID} " data/selection.txt | cut -d' ' -f2)
  ((slt--))
  echo -en "${TOPICS[$slt]}\n\n"
done
