#!/bin/bash

git -C /home/ubuntu/Enzyme fetch
HEADHASH=$(git -C /home/ubuntu/Enzyme rev-parse HEAD)
UPSTREAMHASH=$(git -C /home/ubuntu/Enzyme rev-parse main@{upstream})

if [ "$HEADHASH" != "$UPSTREAMHASH" ]
  then
    bash /home/ubuntu/enzyme-explorer/build.sh 
    exit 0
  else
    echo -e ${FINISHED}Current branch is up to date with origin/master.${NOCOLOR}
fi
