#!/bin/bash
# (Standard) Layered Registry-Managed migration - to be executed at the source


# NOTE: the registry has to be running and reachable!
# docker run -d -p 5000:5000 --restart=on-failure --name registry registry:2

# TODO: errors handling

if [ $# -ne 3 ] && [ $# -ne 4 ]; then
	echo "Required arguments: TO_HOST REGISTRY_TAG (IMAGE TAG)|(CONTAINER)"
	exit 1
fi

TO_HOST=$1
REGISTRY_TAG=$2
USER='ubu2admin' # if the same it can be omitted

if [ $# -eq 3 ]; then
	CONTAINER=$3
	
	# given a container, find out which image it is using
	IMAGE_TAG=$(docker container inspect $CONTAINER -f '{{.Config.Image}}')
	IMAGE=$(echo $IMAGE_TAG | cut -d: -f1)
	TAG=$(echo $IMAGE_TAG | cut -d: -f2)
else
	IMAGE=$3
	TAG=$4
	IMAGE_TAG="$IMAGE:$TAG"
fi

# no need to commit for stateless service
# {
# new image from a container (default: container stopped while the commit is created)
# docker commit $CONTAINER $IMAGE:$TAG
# (no volumes)
# }

# NOTE: push or pull operations may be LOCAL, depending on the location of the registry
# in any case, just the layers not already present are transferred

docker tag $IMAGE_TAG $REGISTRY_TAG
docker push $REGISTRY_TAG


# ################ execute script on peer ################
ssh $USER@$TO_HOST "docker pull $REGISTRY_TAG"

# (check result)
# ssh $USER@$TO_HOST "docker image ls"

# start container from image
ssh $USER@$TO_HOST "docker run -d -p 8080:8080 $REGISTRY_TAG"
# TODO: generic port mapping

# (stop container at the source)
# TODO: ...

# docker container ls -a
# (docker ps -a)
# docker container stop CONTAINER	# The main process inside the container will receive SIGTERM, and after a grace period, SIGKILL
# docker container rm CONTAINER
# docker image rm IMAGE_TAG
# (docker rmi IMAGE_TAG)
# docker image ls
