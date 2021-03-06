#!/bin/bash

# curl -o out_file.txt -D header_file.txt

# $1 := <REGISTRY_ADDR>
# $2 := (catalog|list|repos) | <REPO>
# $3 := <TAG> | <DIGEST>
# $4 := <FILE_NAME>
# $5 := layer | config

REGISTRY=$1

if [ $# -eq 1 ]; then
	curl -v $REGISTRY/v2/ 	# check endpoint

elif [ $# -eq 2 ] && [[ $2 =~ ^(catalog|list|repos)$ ]]; then 	# list repositories
	# $2 := catalog|list|repos
	curl -v $REGISTRY/v2/_catalog

elif [ $# -eq 2 ]; then 	# list tags
	# $2 := <REPO>
	curl -v $REGISTRY/v2/$2/tags/list

elif [ $# -eq 3 ]; then 	# check manifest existence
	# $3 := <TAG>
	curl -v $REGISTRY/v2/$2/manifests/$3 \
		-I -X HEAD \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json"

elif [ $# -eq 4 ]; then 	# get manifest
	# $4 := <FILE_NAME>
	curl -v $REGISTRY/v2/$2/manifests/$3 -o "$4" \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json"

elif [ $# -eq 5 ] && [ $5 = "layer" ]; then 	# get layer
	# $3 := <DIGEST>
	# $5 := layer
	curl -v $REGISTRY/v2/$2/blobs/$3 -o "$4" \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip" # layer

elif [ $# -eq 5 ] && [ $5 = "config" ]; then 	# get config
	# $5 := config
	curl -v $REGISTRY/v2/$2/blobs/$3 -o "$4" \
		-H "Accept: application/vnd.docker.container.image.v1+json" # config

else
	COMMON="$(basename "$0") <REGISTRY_ADDR>"
	echo "Usage:"
	echo -e "$COMMON \n\t check endpoint"
	echo -e "$COMMON catalog \n\t list repositories"
	echo -e "$COMMON <REPO> \n\t list tags"
	echo -e "$COMMON <REPO> <TAG> \n\t check manifest existence"
	echo -e "$COMMON <REPO> <TAG> <FILE_NAME> \n\t get manifest"
	echo -e "$COMMON <REPO> <DIGEST> <FILE_NAME> layer \n\t get layer"
	echo -e "$COMMON <REPO> <DIGEST> <FILE_NAME> config \n\t get config"
fi

# https://docs.docker.com/engine/reference/commandline/manifest_inspect/
# in $HOME/.docker/config.json
#	{ "experimental": "enabled" }
# sudo docker manifest inspect -v <MANIFEST(IMAGE)>	# -v verbose
