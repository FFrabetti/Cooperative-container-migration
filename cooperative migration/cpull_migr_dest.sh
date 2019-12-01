#!/bin/bash
# Centralized Pull-based migration - to be executed at the destination

# TODO: handle errors ...

# NOTE: a Registry has to be running on each node

# $1 := <SOURCE_REGISTRY>
# $2 := <IMAGE_REPO>
# $3 := <IMAGE_TAG>
# $4 := <CENTRAL_REGISTRY>
# $5 := [<DEST_REGISTRY>]

SOURCE_REGISTRY=$1
IMAGE_REPO=$2
IMAGE_TAG=$3
CENTRAL_REGISTRY=$4
DEST_REGISTRY="localhost:5000"

if [ $# -eq 5 ]; then
	DEST_REGISTRY=$5
fi

# test local Registry
# curl -v $DEST_REGISTRY/v2/

# set PATH so to find other scripts in the same dir
TMP_PATH=$PATH 	# just in case I ever need the original PATH
DIR=$(dirname "$0")
PATH="$PATH:$DIR"

MANIFEST_FILE="$(echo $IMAGE_REPO | sed 's/\//./g').$IMAGE_TAG.mnf"

# 1. from an image (repository and tag), get the digests of its layers
# DIGESTS=$(registry_api.sh $SOURCE_REGISTRY $IMAGE_REPO $IMAGE_TAG)
curl_registry_api.sh $SOURCE_REGISTRY $IMAGE_REPO $IMAGE_TAG "$MANIFEST_FILE"
DIGESTS=$(cat "$MANIFEST_FILE" | python3 -c "import sys, json;
for l in json.load(sys.stdin)['layers']:
	print(l['digest'])
")

NR_LAYERS=$(echo "$DIGESTS" | wc -l)
echo "$NR_LAYERS layers found for $IMAGE_REPO:$IMAGE_TAG"

# 2. for each layer, check if it is present locally (and if so, mount it in the target repository)
# nested loops: for each layer, for each repo
REPOS=$(registry_api.sh $DEST_REGISTRY)

echo "Checking local repositories:"
echo "$REPOS"
echo "--------"

# TODO: check if IMAGE+TAG is already present at the destination
# TODO: check layers first in the same repository, if present (e.g. for previous versions)

newlayers=()

for DIGEST in $DIGESTS; do
	echo "$DIGEST ... "
	FOUND=""
	while read REPO; do # TODO: check if empty
		if test_layer.sh $DEST_REGISTRY $REPO $DIGEST; then
#			echo "... found in $REPO"
			FOUND="$REPO"
			break
		fi
	done <<< "$REPOS"

	if [ $FOUND ]; then # true if not empty
		echo "layer found in $FOUND"
		
		if [ $FOUND != $IMAGE_REPO ]; then # mount layer from $FOUND to $IMAGE_REPO
			push_layer.sh $DEST_REGISTRY $IMAGE_REPO $DIGEST $FOUND
		fi
	else
		echo "layer NOT found in $DEST_REGISTRY"
		newlayers+=($DIGEST)
	fi
done

# 3. get new layers from remote Registries
URL_FILE="upload_url.tmp"
CONF_FILE="conf_blob.tmp"

# DIGEST --> URL (REGISTRY+REPOSITORY)
# 3.1 get manifest from CENTRAL_REGISTRY
MNF="$(echo $IMAGE_REPO | sed 's/\//./g').$IMAGE_TAG.urls.mnf"
curl -Ss $CENTRAL_REGISTRY/v2/$IMAGE_REPO/manifests/$IMAGE_TAG \
	-o "$MNF" \
	-H "Accept: application/vnd.docker.distribution.manifest.v2+json"

# 3.2 for each new layer: parse JSON and get an URL (chosen with a certain policy)
for DIGEST in ${newlayers[@]}; do
	URL=$(cat "$MNF" | python3 $DIR/get_url_from_digest.py $DIGEST)
	echo "fetching layer from: $URL/$DIGEST"
	curl -sS "$URL/$DIGEST" -o "${DIGEST}_layer.out" \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip" # layer

# 4.1 push layer (get upload URL and PUT)
	echo "pushing layer $DIGEST ..."
	LEN=$(stat --printf="%s" "${DIGEST}_layer.out") # %s	total size, in bytes
	
	rm "$URL_FILE" # if present, get_upload_url.sh checks upload status
	get_upload_url.sh $DEST_REGISTRY $IMAGE_REPO "$URL_FILE"
	push_layer.sh $DEST_REGISTRY $IMAGE_REPO $DIGEST $LEN $(cat "$URL_FILE") "${DIGEST}_layer.out"
done

# 4.2 (get manifest, get config blob) push config and manifest
CONF_DGST=$(cat "$MANIFEST_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin)['config']['digest'])")
CONF_LEN=$(cat "$MANIFEST_FILE" | python3 -c "import sys, json; print(json.load(sys.stdin)['config']['size'])")
curl_registry_api.sh $SOURCE_REGISTRY $IMAGE_REPO $CONF_DGST "$CONF_FILE" config

rm "$URL_FILE" # if present, get_upload_url.sh checks upload status
get_upload_url.sh $DEST_REGISTRY $IMAGE_REPO "$URL_FILE" config
push_config.sh $CONF_DGST $CONF_LEN $(cat "$URL_FILE") "$CONF_FILE"
push_manifest.sh $DEST_REGISTRY $IMAGE_REPO $IMAGE_TAG "$MANIFEST_FILE"

# 5. run a container from the newly formed image
# (check layers)
NR_LAYERS_DEST=$(registry_api.sh $DEST_REGISTRY $IMAGE_REPO $IMAGE_TAG | wc -l) 	# list and count layers

if [ $NR_LAYERS -eq $NR_LAYERS_DEST ]; then
	docker run -d -p 8080:8080 $DEST_REGISTRY/$IMAGE_REPO:$IMAGE_TAG
	# curl localhost:8080
else
	echo "$NR_LAYERS_DEST layers found, $NR_LAYERS expected"
fi


# (clean up temp files)
# rm *_layer.out
rm "$URL_FILE"
# rm "$MANIFEST_FILE"
rm "$CONF_FILE"
