FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && apt-get install -y autoconf bison flex gcc g++ git \ 
    libprotobuf-dev libnl-route-3-dev libtool make pkg-config protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

RUN git clone -b master --single-branch --depth=1 https://github.com/google/nsjail.git

RUN cd /nsjail && make && mv /nsjail/nsjail /bin && rm -rf -- /nsjail


FROM ubuntu:20.04

COPY --from=builder /bin/nsjail /bin/nsjail

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && apt-get install -y curl \ 
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get update && apt-get install -y --no-install-recommends gcc nodejs git make binutils build-essential \
    && apt-get autoremove -y --purge \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 999 compiler \
    && useradd -r -u 999 -m -d /app -g compiler compiler \
    && cgcreate -a compiler:compiler -g memory,pids,cpu,net_cls:ce-sandbox \
    && cgcreate -a compiler:compiler -g memory,pids,cpu,net_cls:ce-compile

USER compiler

RUN git clone -b main --single-branch --depth=1 https://github.com/EnzymeAD/compiler-explorer /app/compiler-explorer && make -C /app/compiler-explorer prebuild

WORKDIR /app/compiler-explorer

ENV DEBIAN_FRONTEND=

ENV EXTRA_ARGS="--env enzyme"

ENTRYPOINT ["sh", "-c", "make", "run-only"]
