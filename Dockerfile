FROM alpine:latest

RUN apk add ansible opentofu

WORKDIR /modules

ENTRYPOINT ["tofu"]