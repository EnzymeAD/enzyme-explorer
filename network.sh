#!/bin/sh

for container in $(docker ps -q --filter label="explorer")
do
  docker network disconnect -f docker_gwbridge $container
  echo removed $container
done
