FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl \ 
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update && apt-get install -y --no-install-recommends nodejs git make binutils build-essential \
    && apt-get autoremove -y --purge \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 999 compiler \
    && useradd -r -u 999 -m -d /app -g compiler compiler \
    && mkdir -p /local/juliapackages && chown compiler:compiler /local/juliapackages

USER compiler

RUN git clone -b main --single-branch --depth 1 https://github.com/EnzymeAD/compiler-explorer /app/compiler-explorer && make -C /app/compiler-explorer prebuild

WORKDIR /app/compiler-explorer

ENV DEBIAN_FRONTEND=
ENV JULIA_DEPOT_PATH=/local/juliapackages:/opt/compiler-explorer/juliapackages
ENV JULIA_PKG_SERVER=http://package-proxy:8000
ENV EXTRA_ARGS="--env enzyme"

ENTRYPOINT ["sh", "-c", "make", "run-only"]
