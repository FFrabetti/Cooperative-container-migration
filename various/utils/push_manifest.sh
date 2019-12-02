#!/bin/bash

# pushing an image manifest
# https://docs.docker.com/registry/spec/api/#pushing-an-image-manifest

# $1 := <REGISTRY>
# $2 := <REPO>
# $3 := <TAG>
# $4 := <MANIFEST_FILE>

REGISTRY=$1
REPO=$2
TAG=$3
MANIFEST_FILE="$4"

# PULL manifest
# ./curl_registry_api.sh $FROM_REGISTRY $REPO $TAG "$MANIFEST_FILE"

curl -v "$REGISTRY/v2/$REPO/manifests/$TAG" \
	-X PUT \
	-H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" \
	--data @"$MANIFEST_FILE"
