#!/bin/bash

TAG=$1
SIZE=$2

function tagAndPush {
	local image=$1
	local prev=$2
	local seq=$3
	local reg=$4
	
	docker tag $image:$prev $reg/$image:$seq
	docker push $reg/$image:$seq
}


if [ $(docker ps -q --filter 'name=^sec_registry$') ]; then
	echo "sec_registry already running"
else
	local_registry.sh certs
fi

# https://github.com/moby/moby/blob/10c0af083544460a2ddc2218f37dc24a077f7d90/docs/reference/commandline/images.md#filtering
filter="reference=trafficgen:$TAG"
if [ ! "$(docker image ls -q --filter $filter)" ]; then
	echo "Build trafficgen image for $TAG $SIZE"
	build_trafficgen.sh $TAG $SIZE
fi


while read registry imgtag; do
	tagAndPush trafficgen $imgtag $imgtag $registry
done
