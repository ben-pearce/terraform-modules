docker build -t tofu .
docker run -it -v $(dirname $(realpath "$0")):/modules -v ~/:/root tofu "$@"
