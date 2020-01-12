#!/bin/bash

# $1 := REGISTRY
# $2 := REPO
# $3 := VERS
# $4 := MASTER

REGISTRY=$1
REPO=$2
VERS=$3
MASTER=$4

source ./registry-functions.sh
UPDATE_MNF_PY="$(pwd)/update_manifest.py"

DIR=$(mktemp -d)
cd "$DIR"
pwd

if curl_test_ok "https://$REGISTRY/v2/$REPO/manifests/$VERS"; then
	echo "Container already pushed to the Registry"
else
	for i in $(seq 1 1000); do
		echo "Lorem ipsum dolor sit amet $i" >> layerfile
	done

	# 2 layers container image
	{
		echo "FROM busybox"
		echo "COPY layerfile ."
	} > Dockerfile

	docker build -t "$REGISTRY/$REPO:$VERS" .
	docker push "$REGISTRY/$REPO:$VERS"
fi

# the master has to have it as well
if curl_test_ok "https://$MASTER/v2/$REPO/manifests/$VERS"; then
	echo "Container already pushed to the master"
else
	docker tag "$REGISTRY/$REPO:$VERS" "$MASTER/$REPO:$VERS"
	docker push "$MASTER/$REPO:$VERS"
fi

# but with the list of URLs for each layer
# - first layer ("bottom"): can be fetched from both master and destination
# - second layer ("top"): can be fetched just from the source

getManifest "https://$MASTER" $REPO $VERS > manifest

for d in $(getLayersDigests < manifest); do
	if [ $notFirst ]; then
		python3 "$UPDATE_MNF_PY" $d "https://$REGISTRY/v2/$REPO/blobs" > manifest3 < manifest2
	else
		notFirst="true"
		python3 "$UPDATE_MNF_PY" $d "https://$MASTER/v2/$REPO/blobs" "https://$REGISTRY/v2/$REPO/blobs" > manifest2 < manifest
	fi
done

pushManifest "https://$MASTER" $REPO $VERS < manifest3
