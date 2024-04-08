FROM --platform=$BUILDPLATFORM golang:alpine AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG VERSION
ARG CGO_ENABLED=on

ENV GOOS=$TARGETOS \
  GOARCH=$TARGETARCH

RUN set -xe && \
  apk add --no-cache --virtual .build-deps \
  build-base \
  curl \
  git \
  libcap && \
  mkdir -p /root/xray-src && \
  cd /root/xray-src && \
  curl -sSL https://github.com/XTLS/Xray-core/archive/v$VERSION.tar.gz | tar xz --strip 1 && \
  LDFLAGS="-s -w -buildid=" && \
  go build -v -o /xray -trimpath -ldflags "$LDFLAGS" ./main && \
  setcap 'cap_net_bind_service=+ep' /xray && \
  curl -sSL https://github.com/v2ray/geoip/raw/release/geoip.dat -o /geoip.dat && \
  curl -sSL https://github.com/v2ray/domain-list-community/raw/release/dlc.dat -o /geosite.dat

# FROM alpine:3.19
FROM --platform=${TARGETPLATFORM} ubuntu:latest
RUN mkdir /scripts && \
  mkdir -p /var/log/xray && \
  mkdir -p /usr/local/etc/xray && \
  mkdir -p /usr/local/etc/hysteria
COPY scripts /scripts

RUN apk-get install --no-cache ca-certificates


COPY --from=builder /xray /usr/bin/
COPY --from=builder /geo* /usr/bin/
COPY config.json /usr/local/etc/xray/

CMD ["xray", "-config=/usr/local/etc/xray/config.json"]
