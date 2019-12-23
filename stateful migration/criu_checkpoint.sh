#!/bin/bash

# $1 := CONTAINER
# $2 := CHECKPOINT
# [$3 := CHECKPT_DIR]

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
	echo "Usage: $0 CONTAINER CHECKPOINT [CHECKPT_DIR]"
	exit 1
fi

CONTAINER=$1
CHECKPOINT=$2

SRC_DIR=$(pwd)
if [ $# -eq 3 ]; then
	mkdir -p "$3"
	cd "$3"
fi

# --leave-running 		Leave the container running after checkpoint
# docker container ls

# remember to use an absolute path for --checkpoint-dir
docker checkpoint create $CONTAINER $CHECKPOINT --checkpoint-dir="$(pwd)"
sudo tar cvf "$SRC_DIR/$CONTAINER.$CHECKPOINT.tar" $CHECKPOINT

# See:
# https://criu.org/Docker
# --security-opt seccomp:unconfined
# https://docs.docker.com/engine/security/seccomp/
