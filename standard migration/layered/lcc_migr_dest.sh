#!/bin/bash
# (Standard) Layered Custom-Client migration - to be executed at the destination

# NOTE: a Registry has to be running both at the source and at the destination

# $1 := <SOURCE_ADDR>
# $2 := <IMAGE_REPO>
# $3 := <IMAGE_TAG>

LOCAL_REG="localhost:5000"

# test local Registry
# curl -v $LOCAL_REG/v2/

# 1. from an image name (repository and tag), get the list of the digests of all its layers
DIGESTS=$(./registry_api.sh $1 $2 $3)

echo "$(echo "$DIGESTS" | wc -l) layers found"

# 2. for each layer, check if it is present locally (and if so, in which repository)
# nested loops: for each layer, for each repo
REPOS=$(./registry_api.sh $LOCAL_REG)

echo "Checking layers presence in local repositories:"
echo "$REPOS"
echo "--------"

newlayers=()

for DIGEST in $DIGESTS; do
	echo "$DIGEST ... "
	FOUND=""
	while read REPO; do
		if ./test_layer.sh $LOCAL_REG $REPO $DIGEST; then
#			echo "... found in $REPO"
			FOUND="$REPO"
			break
		fi
	done <<< "$REPOS"

	if [ $FOUND ]; then
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

curl -sS "$1/v2/$2/blobs/{$CS_DGSTS}" -o "$OUT_FILE_PATH/#1_layer.out" \
	-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip" # layer

# 4. push/create image: manifest + local layers (imported from other repos) + new layers


# 5. run a container from the newly formed image

