#!/bin/bash
# (Standard) "Simple" StateLess migration - to be executed at the source


# to run a container from an image and test it (REST):
# 	docker run -d -p HOST_PORT:CONT_PORT IMAGE:TAG
# 	curl localhost:HOST_PORT

# TODO: errors handling

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
	echo "Required arguments: TO_HOST (IMAGE TAG)|(CONTAINER)"
	exit 1
fi

TO_HOST=$1
USER='ubu2admin' # if the same it can be omitted

if [ $# -eq 2 ]; then
	CONTAINER=$2
	
	# given a container, find out which image it is using
	IMAGE_TAG=$(docker container inspect $CONTAINER -f '{{.Config.Image}}')
	IMAGE=$(echo $IMAGE_TAG | cut -d: -f1)
	TAG=$(echo $IMAGE_TAG | cut -d: -f2)
else
	IMAGE=$2
	TAG=$3
	IMAGE_TAG="$IMAGE:$TAG"
fi

# replace / with .
TAR_NAME=$(echo $IMAGE | sed 's/\//./g').$TAG.tar
LOCAL_PATH=./$TAR_NAME
REMOTE_DIR=/tmp/

# no need to commit for stateless service
# {
# new image from a container (default: container stopped while the commit is created)
# docker commit $CONTAINER $IMAGE:$TAG
# (no volumes)
# }

# TODO: skip docker save if a local backup for the same image already exists
# - unique file name using the digest
# - file name based on image name, but either calculate the digest or keep a mapping table

# backup (tar) from an image
docker save -o $LOCAL_PATH $IMAGE_TAG
# (no volumes)

# send backup to destination
scp $LOCAL_PATH $USER@$TO_HOST:$REMOTE_DIR

# TODO: docker save and backup send operations may be pipelined (not with scp, though [?])
# similar pipeline with reception and docker load


# ################ execute script on peer ################
# load image from tar
ssh $USER@$TO_HOST "docker load -i ${REMOTE_DIR}${TAR_NAME}"

# (check result)
ssh $USER@$TO_HOST "docker image ls"

# start container from image
ssh $USER@$TO_HOST "docker run -d -p 8080:8080 $IMAGE_TAG"
# TODO: generic port mapping

# (clean up)
ssh $USER@$TO_HOST "rm ${REMOTE_DIR}${TAR_NAME}"
# or keep it for future uses (migrations FROM this node)

# (stop container at the source)
# TODO: ...

# docker container ls -a
# (docker ps -a)
# docker container stop CONTAINER	# The main process inside the container will receive SIGTERM, and after a grace period, SIGKILL
# docker container rm CONTAINER
# docker image rm IMAGE_TAG
# (docker rmi IMAGE_TAG)
# docker image ls
