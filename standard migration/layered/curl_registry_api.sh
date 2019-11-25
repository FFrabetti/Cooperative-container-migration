#!/bin/bash

# curl -o out_file.txt -D header_file.txt

# $1 := <REGISTRY_ADDR>

if [ $# -eq 1 ]; then
	# check endpoint
	curl -v $1/v2/

elif [ $# -eq 2 ] && [[ $2 =~ ^(catalog|list|repos)$ ]]; then # [ $2 -eq "catalog" ]; then
	# $2 := catalog|list|repos
	curl -v $1/v2/_catalog

elif [ $# -eq 2 ]; then
	# $2 := <REPO>
	curl -v $1/v2/$2/tags/list
	
elif [ $# -eq 3 ]; then
	# $2 := <REPO>
	# $3 := <TAG>
	curl -v $1/v2/$2/manifests/$3 \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json"

elif [ $# -eq 4 ] && [ $4 = "head" ]; then
	# $4 := head
	curl -v $1/v2/$2/manifests/$3 \
		-I -X HEAD \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json"

elif [ $# -eq 4 ] && [ $4 = "config" ]; then
	# $3 := <DIGEST>
	# $4 := config
	curl -v $1/v2/$2/blobs/$3 \
		-H "Accept: application/vnd.docker.container.image.v1+json" # config

elif [ $# -eq 4 ]; then
	# $4 := <FILE_NAME>
	curl -v $1/v2/$2/blobs/$3 -o $4 \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip" # layer
		
else
	SHNAME=$(basename "$0")
	COMMON="$SHNAME <REGISTRY_ADDR>"
	echo "Usage:"
	echo -e "$COMMON \n\t check endpoint"
	echo -e "$COMMON catalog \n\t list repositories"
	echo -e "$COMMON <REPO> \n\t list tags"
	echo -e "$COMMON <REPO> <TAG> \n\t get manifest"
	echo -e "$COMMON <REPO> <TAG> head \n\t check manifest existence"
	echo -e "$COMMON <REPO> <DIGEST> config \n\t get config"
	echo -e "$COMMON <REPO> <DIGEST> <FILE_NAME> \n\t get layer"
fi

# https://docs.docker.com/engine/reference/commandline/manifest_inspect/
# in $HOME/.docker/config.json
#	{ "experimental": "enabled" }
# sudo docker manifest inspect -v <MANIFEST(IMAGE)>	# -v verbose