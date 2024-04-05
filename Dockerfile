FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG CGO_ENABLED=0
ARG TAG
ARG REPOSITORY

WORKDIR /root
RUN apk add --update git \
  && git clone https://github.com/${REPOSITORY} mosdns \
  && cd ./mosdns \
  && git fetch --all --tags \
  && git checkout tags/${TAG} \
  && go build -ldflags "-s -w -X main.version=${TAG}" -trimpath -o mosdns

FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer="fordes123 <github.com/fordes123>"

ENV TZ=Asia/Shanghai \
  CRON="0 0 */7 * *"

USER root
WORKDIR /etc/mosdns
COPY --from=builder /root/mosdns/mosdns /usr/bin/
COPY scripts /scripts
COPY config/* /etc/mosdns/

RUN apk add --no-cache ca-certificates wget dcron tzdata bash curl git \
  && cd /tmp && git clone https://github.com/systemd/systemd \
  && echo "unicode=\"YES\"" >> /etc/rc.conf && \
  apk add --no-cache --virtual .build_deps \
  autoconf file g++ gcc libc-dev make pkgconf python3 ninja \
  util-linux pciutils usbutils coreutils binutils findutils grep \
  build-base gcc abuild binutils binutils-doc gcc-doc gperf libcap libcap-dev \
  valgrind-dev \
  && \
  pip3 install meson

RUN cd /tmp/systemd && \
  meson build && \
  ninja build \
  && apk add systemd alpine-sdk automake m4 autoconf libtool fuse fuse-dev linux-vanilla-dev linux-headers libnih-dev linux-pam-dev \
  && chmod a+x /scripts/* \
  && /scripts/update.sh \
  && /scripts/install-xray.sh > xray.log || cat xray.log

VOLUME /etc/mosdns
EXPOSE 53/udp 53/tcp
ENTRYPOINT [ "/scripts/entrypoint.sh" ]
