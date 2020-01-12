#!/bin/bash
# Centralized Pull-based container image migration - to be executed at the destination

# $1 := <SRC_REGISTRY>
# $2 := <IMAGE>
# $3 := <CENTRAL_REGISTRY>
# [$4 := <DEST_REGISTRY>]

PATH="$PATH:$(dirname "$0")"
source registry-functions.sh

SRC_REGISTRY=$1
IMAGE=$2
CENTRAL_REGISTRY=$3
DEST_REGISTRY=$4

if [ $# -eq 3 ]; then
	for ip in $(hostname -I); do
	if curl_test_ok "https://$ip/v2/"; then
		DEST_REGISTRY=$ip
	fi
	done
	[ $DEST_REGISTRY ] || { echo "No local Registry found"; exit 1; }
	DEST_REGISTRY="https://$DEST_REGISTRY"
fi

REPO=$(echo $IMAGE | cut -d: -f1)
VERS=$(echo $IMAGE | cut -d: -f2)

# check if the image is already present at the destination
if curl_test_ok "$DEST_REGISTRY/v2/$REPO/manifests/$VERS"; then
	echo "Image already at the destination"
	exit 0
fi

MANIFEST_FILE="./$IMAGE.mnf"
getManifest "$CENTRAL_REGISTRY" $REPO $VERS > "$MANIFEST_FILE"

# for each layer, check if it is present locally (and if so, mount it in the target repository)
# nested loops: for each layer, for each repo
REPOS=$(getRepositories "$DEST_REGISTRY")

echo "Checking local repositories: $REPOS"

# TODO: check layers first in the same repository, if present (e.g. for previous versions)

for d in $(getLayersDigests < "$MANIFEST_FILE"); do
	echo "$d ... "
	FOUND=""
	while read r; do
		if curl_test_ok "$DEST_REGISTRY/v2/$r/blobs/$d"; then
			FOUND="$r"
			break
		fi
	done <<< "$REPOS"

	if [ $FOUND ]; then
		echo "layer found in $FOUND"
		
		if [ $FOUND != $REPO ]; then # mount layer from $FOUND to $REPO
			blobMount "$DEST_REGISTRY" $REPO $d $FOUND
		fi
	else
		echo "layer NOT found in $DEST_REGISTRY"

		# for each new layer: parse JSON and get an URL (chosen with a certain policy)
		{
			url=$(python3 get_url_from_digest.py $d < "$MANIFEST_FILE")
			if [ ! $url ]; then 	# fallback from the CENTRAL_REGISTRY
				url="$CENTRAL_REGISTRY/v2/$REPO/blobs"
				echo "No URL found, using $url"
			fi
			
			echo "fetching layer from: $url/$d"
			layer_file=$(mktemp)
			getLayer "$url/$d" > "$layer_file"

			# 4.1 push layer (get upload URL and PUT)
			len=$(stat --printf="%s" "$layer_file") # %s	total size, in bytes
			
			uploadUrl=$(getUploadUrl "$DEST_REGISTRY" $REPO)
			pushLayer "$uploadUrl" $d $len  < "$layer_file"
		} & 	# background
	fi
done

echo "Waiting for all transfers to finish..."
wait

# (get manifest, get config blob) push config and manifest
read CONF_DGST CONF_LEN < <(getConfigDigestSize < "$MANIFEST_FILE")
CONF_URL=$(getUploadUrl "$DEST_REGISTRY" $REPO config)

getConfig "$SRC_REGISTRY" $REPO $CONF_DGST | pushConfig "$CONF_URL" $CONF_DGST $CONF_LEN
pushManifest "$DEST_REGISTRY" $REPO $VERS < "$MANIFEST_FILE"


# clean up:
# rm "$MANIFEST_FILE"
# or use: MANIFEST_FILE=$(mktemp)
