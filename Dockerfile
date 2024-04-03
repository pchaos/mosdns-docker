FROM --platform=${TARGETPLATFORM} golang:latest as builder
ARG CGO_ENABLED=0
ARG TAG
ARG REPOSITORY

WORKDIR /root
RUN dnf install -y git \
  && git clone https://github.com/${REPOSITORY} mosdns \
  && cd ./mosdns \
  && git fetch --all --tags \
  && git checkout tags/${TAG} \
  && go build -ldflags "-s -w -X main.version=${TAG}" -trimpath -o mosdns

# FROM --platform=${TARGETPLATFORM} fedora:latest
FROM --platform=${TARGETPLATFORM} ubuntu:22.04
LABEL maintainer="fordes123 <github.com/fordes123>"

ENV TZ=Asia/Shanghai \
  CRON="0 0 */7 * *"

USER root
WORKDIR /etc/mosdns
COPY --from=builder /root/mosdns/mosdns /usr/bin/
COPY scripts /scripts
COPY config/* /etc/mosdns/

RUN dnf install -y ca-certificates wget cronie tzdata \
  && chmod a+x /scripts/* \
  && /scripts/update.sh

VOLUME /etc/mosdns
EXPOSE 53/udp 53/tcp
ENTRYPOINT [ "/scripts/entrypoint.sh" ]

