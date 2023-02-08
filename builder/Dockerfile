FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends curl git cron moreutils make cmake ccache clang ninja-build binutils python3.10-venv grep build-essential \
    && apt-get autoremove -y --purge \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN git clone -b main --single-branch --depth=1 https://github.com/EnzymeAD/compiler-explorer /app/ce \
    && mkdir -p /app/template && mv /app/ce/etc/config /app/template && rm -rf /app/ce

RUN git clone -b main --single-branch --depth=1 https://github.com/compiler-explorer/infra.git /app/infra && make -C /app/infra ce

RUN git clone -b main https://github.com/EnzymeAD/Enzyme.git /app/Enzyme

RUN ccache -M 10G

COPY install-compilers.sh /app/install-compilers.sh
COPY install-libraries.sh /app/install-libraries.sh
COPY build-enzyme.sh /app/build-enzyme.sh
COPY check-upstream.sh /app/check-upstream.sh
COPY entrypoint.sh /app/entrypoint.sh
COPY update-explorer.sh /app/update-explorer.sh
COPY crontab /etc/cron.d/crontab
COPY --from=docker:23.0.0-dind /usr/local/bin/docker /usr/local/bin/

RUN chmod +x /app/install-libraries.sh \
    && chmod +x /app/install-compilers.sh \
    && chmod +x /app/build-enzyme.sh \
    && chmod +x /app/check-upstream.sh \
    && chmod +x /app/entrypoint.sh \
    && chmod +x /app/update-explorer.sh \
    && chmod +x /etc/cron.d/crontab && crontab /etc/cron.d/crontab

WORKDIR /app

ENV DEBIAN_FRONTEND=

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["cron","-f", "-l", "2"]
