FROM quay.io/projectquay/golang:1.20 as builder

ARG TARGETOS
ARG TARGETARCH
WORKDIR /go/src/app
COPY . .
RUN make build TARGETOS=$TARGETOS TARGETARCH=$TARGETARCH

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kuberbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kuberbot"]
