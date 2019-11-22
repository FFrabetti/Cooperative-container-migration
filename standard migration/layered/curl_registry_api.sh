#!/bin/bash

# curl -o out_file.txt -D header_file.txt

# $1 := <REGISTRY_ADDR>

if [ $# -eq 1 ]; then
	# check endpoint
	curl -v https://$1/v2/

else if [ $# -eq 2 ]; then
	# $2 := <QUERY>
	# e.g.	<QUERY> := _catalog
	# 		<QUERY> := <REPO>/tags/list
	curl -v https://$1/v2/$2
	
else if [ $# -eq 3 ]; then
	# $2 := <REPO>
	# $3 := <TAG>
	curl -v https://$1/v2/$2/manifests/$3 \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json"

else if [ $# -eq 4 ] && [ $4 -eq "head" ]; then
	# $4 := head
	curl -v https://$1/v2/$2/manifests/$3 \
		-I -X HEAD \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json"

else if [ $# -eq 4 ] && [ $4 -eq "config" ]; then
	# $3 := <DIGEST>
	# $4 := config
	curl -v https://$1/v2/$2/blobs/$3 \
		-H "Accept: application/vnd.docker.container.image.v1+json" # config

else
	# $4 := <ANY> (not used)
	curl -v https://$1/v2/$2/blobs/$3 \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip" # layer	
fi

# https://docs.docker.com/engine/reference/commandline/manifest_inspect/
# in $HOME/.docker/config.json
#	{ "experimental": "enabled" }
# sudo docker manifest inspect -v <MANIFEST>	# -v verbose
