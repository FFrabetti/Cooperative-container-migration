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

SRC_DIR=$(pwd) 	# original current directory (where the tar file will be created)
CHECKPT_DIR="$CONTAINER/checkpoint"
if [ $# -eq 3 ]; then
	CHECKPT_DIR="$3"
fi
mkdir -p "$CHECKPT_DIR" && cd "$CHECKPT_DIR"
# now the current directory is the one used for checkpoint-dir

# remember to use an absolute path for --checkpoint-dir
docker checkpoint create $CONTAINER $CHECKPOINT --checkpoint-dir="$(pwd)" --leave-running
sudo tar cf "$CONTAINER.$CHECKPOINT.tar" $CHECKPOINT
# $CHECKPOINT is also the name of the directory created by docker checkpointing process


# See:
# https://criu.org/Docker
# --security-opt seccomp:unconfined
# https://docs.docker.com/engine/security/seccomp/
