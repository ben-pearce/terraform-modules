FROM alpine:latest

RUN apk add openssh-client ansible opentofu

WORKDIR /modules

ENTRYPOINT ["tofu"]