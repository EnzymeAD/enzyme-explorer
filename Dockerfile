FROM ubuntu:20.04

EXPOSE 10240

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl \ 
    && curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update && apt-get install -y --no-install-recommends nodejs git make binutils build-essential \
    && apt-get autoremove -y --purge \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 999 compiler \
    && useradd -r -u 999 -m -d /app -g compiler compiler

USER compiler

RUN mkdir -p /app/compiler-explorer
WORKDIR /app/compiler-explorer

RUN curl -L https://github.com/compiler-explorer/compiler-explorer/tarball/main | tar xz -C /app/compiler-explorer --strip-components=1 \
    && make webpack

ENV DEBIAN_FRONTEND=
ENV NODE_OPTIONS='--max-old-space-size=2048'

ENTRYPOINT ["make"]
CMD [ "run" ]
