#!/bin/bash

docker pull ghcr.io/enzymead/enzyme-explorer-builder:latest
docker pull ghcr.io/enzymead/enzyme-explorer:latest

docker service update --force --image ghcr.io/enzymead/enzyme-explorer-builder:latest enzyme_explorer_compiler-builder
docker service update --force --image ghcr.io/enzymead/enzyme-explorer:latest enzyme_explorer_compiler-explorer
