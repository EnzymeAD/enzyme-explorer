#!/bin/bash

env >> /etc/environment

set -x

mv -n /app/template/config /app/compiler-explorer/etc

source /app/install-compilers.sh

source /app/install-libraries.sh

source /app/build.sh

exec "$@"