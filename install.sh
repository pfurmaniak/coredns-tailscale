#!/bin/sh

docker build -t coredns-tailscale:latest .

install -D /go/src/coredns/coredns /usr/local/bin/coredns
mkdir -p /etc/coredns && cp Corefile $_
cp coredns.service /etc/systemd/system/coredns.service

systemctl daemon-reload
systemctl enable coredns.service
systemctl start coredns.service

docker run --rm -i -t -v $(pwd):/go/src/coredns-tailscale coredns-tailscale 