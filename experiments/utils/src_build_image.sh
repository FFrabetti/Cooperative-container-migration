#!/bin/bash

src=$1
dst=$2
tag=$3
size=$4

if [ $(docker ps -q --filter 'name=sec_registry') ]; then
	echo "sec_registry already running"
else
	local_registry.sh certs
fi
	
source registry-functions.sh
if ! curl_test_ok "https://$src/v2/trafficgen/manifests/$tag"; then
	build_trafficgen.sh $tag $size
	docker tag trafficgen:${tag}d 	$src/trafficgen:${tag}d
	docker push                     $src/trafficgen:${tag}d
fi
	
docker tag trafficgen:$tag 		$dst/trafficgen:$tag
docker push                     $dst/trafficgen:$tag
