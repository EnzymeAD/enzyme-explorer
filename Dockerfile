FROM ubuntu:22.04

EXPOSE 10240

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl \ 
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get update && apt-get install -y --no-install-recommends nodejs git make binutils build-essential \
    && apt-get autoremove -y --purge \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 999 compiler \
    && useradd -r -u 999 -m -d /app -g compiler compiler

USER compiler

RUN git clone -b main --single-branch https://github.com/compiler-explorer/compiler-explorer /app/compiler-explorer && make -C /app/compiler-explorer prereqs

WORKDIR /app/compiler-explorer

ENV DEBIAN_FRONTEND=

ENTRYPOINT [ "make" ]
CMD [ "run" ]
