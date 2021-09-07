FROM ubuntu:20.04

EXPOSE 10240

RUN apt-get update && apt-get install -y curl git make binutils build-essential && curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 999 compiler && useradd -r -u 999 -m -d /app -g compiler compiler

USER compiler
RUN mkdir -p /app/compiler-explorer
WORKDIR /app/compiler-explorer

RUN curl -L https://github.com/compiler-explorer/compiler-explorer/tarball/main | tar xz -C /app/compiler-explorer --strip-components=1

ENTRYPOINT ["make"]
