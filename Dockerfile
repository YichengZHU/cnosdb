FROM --platform=$BUILDPLATFORM golang:1.17.5 as builder
ARG TARGETARCH

WORKDIR /go/src/github.com/cnosdb/cnosdb
COPY . /go/src/github.com/cnosdb/cnosdb

# Proxy, You know.
# RUN go env -w GOPROXY=https://goproxy.cn,direct

RUN GOOS=linux GOARCH=$TARGETARCH go install ./...

FROM debian:stretch
COPY --from=builder /go/bin/cnosdb /go/bin/cnosdb/cnosdb-cli /usr/bin/
COPY --from=builder /go/src/github.com/cnosdb/cnosdb/etc/cnosdb.sample.toml /etc/cnosdb/cnosdb.conf

EXPOSE 8086
VOLUME /var/lib/cnosdb

COPY docker/entrypoint.sh /entrypoint.sh
COPY docker/init-cnosdb.sh /init-cnosdb.sh
RUN chmod +x /entrypoint.sh /init-cnosdb.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["cnosdb"]