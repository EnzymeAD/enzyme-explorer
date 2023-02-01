#!/bin/bash

git -C /app/Enzyme fetch

declare -a branches=("main")


for branch in ${branches[@]}; do

   HEADHASH=$(git -C /app/Enzyme rev-parse $branch)
   UPSTREAMHASH=$(git -C /app/Enzyme rev-parse $branch@{upstream})

   if [ "$HEADHASH" != "$UPSTREAMHASH" ] 
   then
      bash /app/build.sh 
      exit 0
   else
      echo -e ${FINISHED}Current branch is up to date with origin/$branch.${NOCOLOR}
   fi

done
