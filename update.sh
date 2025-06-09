#!/bin/bash

docker-compose pull

docker service update --force --image ghcr.io/enzymead/enzyme-explorer-builder:latest enzyme_explorer_compiler-builder
docker service update --force --image ghcr.io/enzymead/enzyme-explorer:latest enzyme_explorer_compiler-explorer
docker service update enzyme_explorer_package-proxy

docker system prune -f