FROM alpine:3.21.3

RUN apk add openssh-client ansible opentofu

WORKDIR /modules

ENTRYPOINT ["tofu"]