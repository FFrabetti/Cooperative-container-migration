#!/bin/bash
# (Standard) Layered Custom-Client migration - to be executed at the destination

# NOTE: a Registry has to be running both at the source and at the destination

# $1 := <SOURCE_REGISTRY>
# $2 := <IMAGE_REPO>
# $3 := <IMAGE_TAG>
# $4 := [<DEST_REGISTRY>]

SOURCE_REGISTRY=$1
IMAGE_REPO=$2
IMAGE_TAG=$3
DEST_REGISTRY="localhost:5000"

if [ $# -eq 4 ]; then
	DEST_REGISTRY=$4
fi

# test local Registry
# curl -v $DEST_REGISTRY/v2/

# 1. from an image name (repository and tag), get the list of the digests of all its layers
DIGESTS=$(./registry_api.sh $SOURCE_REGISTRY $IMAGE_REPO $IMAGE_TAG)

echo "$(echo "$DIGESTS" | wc -l) layers found"

# 2. for each layer, check if it is present locally (and if so, in which repository)
# nested loops: for each layer, for each repo
REPOS=$(./registry_api.sh $DEST_REGISTRY)

echo "Checking layers presence in local repositories:"
echo "$REPOS"
echo "--------"

newlayers=()

for DIGEST in $DIGESTS; do
	echo "$DIGEST ... "
	FOUND=""
	while read REPO; do
		if ./test_layer.sh $DEST_REGISTRY $REPO $DIGEST; then
#			echo "... found in $REPO"
			FOUND="$REPO"
			break
		fi
	done <<< "$REPOS"

	if [ $FOUND ]; then # check if not empty
		echo "layer found in $FOUND"
	else
		echo "layer NOT found"
		newlayers+=($DIGEST)
	fi
done

# 3. get new layers from remote Registry
# curl https://{one,two,three}.whatever.com -o "#1.out"		# --> one.out two.out three.out

CS_DGSTS=$(IFS=","; echo "${newlayers[@]}")
OUT_FILE_PATH="/tmp"

# when using [] or {}, put the full URL within double quotes to avoid the shell from interfering with it
# URLs will be fetched in a sequential manner
curl -sS "$SOURCE_REGISTRY/v2/$IMAGE_REPO/blobs/{$CS_DGSTS}" -o "$OUT_FILE_PATH/#1_layer.out" \
	-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip" # layer

# 4. push/create image: manifest + local layers (imported from other repos) + new layers
# TODO: ...

# 5. run a container from the newly formed image
# TODO: ...
