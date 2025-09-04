FROM golang:latest AS builder-amd64
ENV GOOS=linux
ENV GOARCH=amd64

FROM golang:latest AS builder-arm64
ENV GOOS=linux
ENV GOARCH=arm64

FROM builder-$TARGETARCH$TARGETVARIANT AS final-builder

ARG TARGETARCH

RUN mkdir /build
ADD . /build/
WORKDIR /build
RUN CGO_ENABLED=0 go build -o solaredge-exporter_${TARGETARCH} .

FROM --platform=$TARGETPLATFORM alpine:latest
LABEL name="solaredge-exporter"

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG TARGETPLATFORM
ARG BUILDOS
ARG BUILDARCH
ARG BUILDVARIANT
ARG BUILDPLATFORM
ARG USERNAME=solaredge-exporter
ARG USER_UID=1000
ARG USER_GID=1000

ENV INVERTER_ADDRESS=10.10.20.14
ENV INVERTER_PORT=1502
ENV EXPORTER_INTERVAL=30
ENV INVERTER_CLIENT_ID=0x01

RUN echo "I'm building for $TARGETOS/$TARGETARCH/$TARGETVARIANT"
RUN echo "I'm building on $BUILDOS/$BUILDARCH/$BUILDVARIANT"

RUN echo "builder-$TARGETARCH$TARGETVARIANT"

RUN apk add --upgrade --no-cache wget ca-certificates

COPY -from=final-builder /build/solaredge-exporter_$TARGETARCH /usr/bin/solaredge-exporter

# Create the user
RUN addgroup -g $USER_GID $USERNAME && adduser -D -H -u $USER_UID -G $USERNAME $USERNAME

RUN chmod 755 /usr/bin/solaredge-exporter && chown solaredge-exporter:solaredge-exporter /usr/bin/solaredge-exporter

USER $USERNAME

CMD ["/usr/bin/solaredge-exporter"]
