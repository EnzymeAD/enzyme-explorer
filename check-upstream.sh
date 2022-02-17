#!/bin/bash

git -C /home/ubuntu/Enzyme fetch

declare -a branches=("main" "experimental")


for branch in ${branches[@]}; do

   HEADHASH=$(git -C /home/ubuntu/Enzyme rev-parse $branch)
   UPSTREAMHASH=$(git -C /home/ubuntu/Enzyme rev-parse $branch@{upstream})

   if [ "$HEADHASH" != "$UPSTREAMHASH" ] 
   then
      bash /home/ubuntu/enzyme-explorer/build.sh 
      exit 0
   else
      echo -e ${FINISHED}Current branch is up to date with origin/$branch.${NOCOLOR}
   fi

done
