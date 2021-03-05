FROM golang:alpine AS builder

ENV PORT        3000
ENV PASSWORD    ChangeThis
ENV METHOD      AEAD_CHACHA20_POLY1305
ENV PV          1.3.1
ENV WSPATH="/ChangeThis"

RUN apk update && apk add --no-cache git curl && \
    curl -sL https://github.com/teddysun/xray-plugin/releases/download/v${PV}/xray-plugin-linux-amd64-v${PV}.tar.gz | tar zxC /usr/bin/ && \
    chmod a+x /usr/bin/xray-plugin_linux_amd64
    

WORKDIR /go/src/ss

RUN git clone --progress https://github.com/shadowsocks/go-shadowsocks2.git . && \
    go mod download && \
    CGO_ENABLED=0 go build -o /tmp/ss -trimpath -ldflags "-s -w -buildid=" ./main

FROM alpine
COPY --from=builder /tmp/ss /usr/bin

CMD go-shadowsocks2 -s 'ss://${METHOD}:${PASSWORD}@:${PORT}' \
       -plugin /usr/bin/xray-plugin_linux_amd64 -plugin-opts "server;path=${WSPATH}"
