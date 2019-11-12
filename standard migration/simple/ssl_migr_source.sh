#!/bin/bash

# to run a container from an image and test it:
# 	docker run -d -p HOST_PORT:CONT_PORT REPO:TAG
# 	curl localhost:HOST_PORT

if [ $# -ne 3 ]; then
	echo "Required 3 arguments: REPO TAG TO_HOST"
	exit 1
fi

#CONTAINER='' # just for docker commit
REPO=$1
TAG=$2
USER='ubu2admin' # if the same it can be omitted
TO_HOST=$3

# replace / with .
TAR_NAME=$(echo $REPO | sed 's/\//./g').$TAG.tar
LOCAL_PATH=./$TAR_NAME
REMOTE_DIR=/tmp/

# new image from a container
# docker commit $CONTAINER $REPO:$TAG
# (no volumes)

# backup (tar) from an image
docker save -o $LOCAL_PATH $REPO:$TAG
# (no volumes)

# send backup to destination
scp $LOCAL_PATH $USER@$TO_HOST:$REMOTE_DIR

# ################ execute script on peer ################
# load image from tar
ssh $USER@$TO_HOST "docker load -i ${REMOTE_DIR}${TAR_NAME}"

# (check result)
ssh $USER@$TO_HOST "docker image ls"

# start container from image
ssh $USER@$TO_HOST "docker run -d -p 8080:8080 $REPO:$TAG"

# clean up
ssh $USER@$TO_HOST "rm ${REMOTE_DIR}${TAR_NAME}"

# docker container ls -a
# (docker ps -a)
# docker container stop CONTAINER	# The main process inside the container will receive SIGTERM, and after a grace period, SIGKILL
# docker container rm CONTAINER
# docker image rm $REPO:$TAG
# (docker rmi IMAGE)
# docker image ls
