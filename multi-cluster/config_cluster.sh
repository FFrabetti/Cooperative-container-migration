#!/bin/bash

# https://docs.docker.com/engine/swarm/manage-nodes/
# https://docs.docker.com/engine/swarm/admin_guide/

# $1 := MASTER
# $2 := PEER
# $3 := WORKER
# ...

if [ $# -lt 3 ]; then
	echo "Usage: $0 MASTER PEER WORKER [WORKER...]"
	exit 1
fi

MASTER=$1
PEER=$2
shift
shift

# docker node ls
# docker node inspect self --pretty
# docker node update --label-add foo --label-add bar=baz node-1

# docker node update --availability drain node-1
# docker node promote node-3
# docker swarm leave --force

SWARM_INIT=$(mktemp)
docker swarm init --advertise-addr $MASTER > $SWARM_INIT

ssh $PEER $(docker swarm join-token manager | grep 'join --token')

while (( $# )); do
	ssh $1 $(cat $SWARM_INIT | grep 'join --token')
	shift
done

docker node ls

docker network create -d overlay --attachable proxyntwAB
docker network create -d overlay --attachable clusterA
docker network create -d overlay --attachable clusterB

docker network ls
