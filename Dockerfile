FROM golang:latest AS final-builder
WORKDIR /build
ARG TARGETARCH

ENV GOOS=linux
ENV GOARCH=$TARGETARCH

ADD . /build/

RUN echo "TARGETARCH=$TARGETARCH"
RUN go version
RUN go env GOARCH GOOS
RUN CGO_ENABLED=0 go build -o solaredge-exporter_$TARGETARCH .
RUN ls -l /build/solaredge-exporter_*

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
