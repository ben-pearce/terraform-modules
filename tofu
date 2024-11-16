#!/bin/bash
docker build -t tofu .
docker run -it \
  --user $(id -u):$(id -g) \
  --volume=$(dirname $(realpath "$0")):/modules \
  --volume=${HOME}:${HOME} \
  --volume="/etc/group:/etc/group:ro" \
  --volume="/etc/passwd:/etc/passwd:ro" \
  --volume="/etc/shadow:/etc/shadow:ro" \
  tofu "$@"
