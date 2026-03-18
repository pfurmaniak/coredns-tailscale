FROM golang:alpine AS build
WORKDIR /go/src/coredns
RUN apk add git make && git clone --depth 1 --branch=v1.14.2 https://github.com/coredns/coredns .
COPY . plugin/tailscale
ENV GOFLAGS="-buildvcs=false"
RUN rm plugin/tailscale/go.* && \
    sed -i s/forward:forward/tailscale:tailscale\\nforward:forward/ plugin.cfg && \
    make check && \
    go build

FROM alpine:latest
VOLUME /etc/coredns/Corefile
RUN apk add --no-cache ca-certificates
COPY --from=build --chmod=755 /go/src/coredns/coredns /usr/local/bin/coredns
CMD ["coredns", "-conf", "/etc/coredns/Corefile"]