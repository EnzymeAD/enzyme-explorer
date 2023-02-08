#!/bin/bash

env >> /etc/environment

mv -f /app/template/config /app/compiler-explorer/etc

source /app/install-compilers.sh

source /app/install-libraries.sh

source /app/build-enzyme.sh

exec "$@"
