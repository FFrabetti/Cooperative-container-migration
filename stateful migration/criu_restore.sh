#!/bin/bash

# $1 := CONTAINER
# $2 := CHECKPOINT

if [ $# -ne 2 ]; then
	echo "Usage: $0 CONTAINER CHECKPOINT"
	exit 1
fi

CONTAINER=$1
CHECKPOINT=$2

# scp ...
# docker create ...

# tar from stdin
sudo tar xvf - -C /var/lib/docker/containers/$(docker ps -aq --no-trunc --filter name=$CONTAINER)/checkpoints
# docker ps -aq --> all containers, just numeric IDs

docker start --checkpoint=$CHECKPOINT $CONTAINER

# docker logs $CONTAINER
