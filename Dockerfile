FROM golang:alpine AS builder

ENV GO111MODULE on


RUN apk update && apk add --no-cache git curl && \
    go get github.com/shadowsocks/go-shadowsocks2 && \
    curl -sL https://github.com/teddysun/xray-plugin/releases/download/v${PV}/xray-plugin-linux-amd64-v${PV}.tar.gz | tar zxC /usr/bin/ && \
    chmod a+x /usr/bin/xray-plugin_linux_amd64
    


FROM alpine:edge

ENV PORT        3000
ENV PASSWORD    ChangeThis
ENV METHOD      AEAD_CHACHA20_POLY1305
ENV PV          1.3.1
ENV WSPATH="/ChangeThis"

COPY --from=builder /go/bin/go-shadowsocks2 /usr/bin

CMD /usr/bin/go-shadowsocks2 -s 'ss://${METHOD}:${PASSWORD}@:3000' \
      -plugin /usr/bin/xray-plugin_linux_amd64 -plugin-opts "server;path=${WSPATH}"
