FROM alpine:3.10

RUN apk add alpine-sdk

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
