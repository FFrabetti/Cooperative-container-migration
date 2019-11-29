#!/bin/bash

# push an image layer: get an upload URL
# https://docs.docker.com/registry/spec/api/#pushing-an-image

# $1 := <REGISTRY>
# $2 := <REPOSITORY>
# $3 := <URL_FILE>
# $4 := [config]

if [ $# -ne 3 ] && [ $# -ne 4 ]; then
	echo "Usage: $(basename $0) <REGISTRY> <REPOSITORY> <URL_FILE> [config]"
	exit 1
fi

REGISTRY=$1
REPO=$2
URL_FILE="$3"

CONTENT_TYPE="application/vnd.docker.image.rootfs.diff.tar.gzip" # layer
if [ $# -eq 4 ]; then
	CONTENT_TYPE="application/vnd.docker.container.image.v1+json" # config
fi

if [ ! -f "$URL_FILE" ]; then
	RES=$(curl -sS $REGISTRY/v2/$REPO/blobs/uploads/ \
		-I -X POST \
		-H "Accept: $CONTENT_TYPE" \
		-w "%{http_code}")
	
	# if 202 Accepted response, the upload URL is returned in the Location header
	RES_CODE=$(echo "$RES" | tail -1)
	if [ "$RES_CODE" = "202" ]; then
		echo "ok 202"
		echo "$RES" | grep Location | cut -d" " -f2 > "$URL_FILE"
		exit 0
	else
		echo "no $RES_CODE"
		echo "$RES"
		exit 1
	fi
else 	# check upload status
	URL=$(cat "$URL_FILE")
	URL=${URL%$'\r'} # remove Win CR
	curl -v "$URL"

	# 204 No Content
	# Location: /v2/<name>/blobs/uploads/<uuid>
	# Range: bytes=0-<offset>
	# Docker-Upload-UUID: <uuid>
fi
