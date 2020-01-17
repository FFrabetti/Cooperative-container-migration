#!/bin/bash

# $1 := REGISTRY
# $2 := DIR
# $3 := URL
# ...

if [ $# -lt 3 ]; then
	echo "Usage: $0 REGISTRY DIR URL [URL...]"
	exit 1
fi

REGISTRY=$1
DIR=$2
shift
shift

source $(dirname "$0")/registry-functions.sh
GUFD_PY=$(which get_url_from_digest.py || echo "$(dirname "$0")/get_url_from_digest.py")

while (( $# )); do
	URL=$1 	# /v2/REPO/blobs/DIGEST
	REPO=$(echo $URL | cut -d"/" -f3)
	DIGEST=$(echo $URL | cut -d"/" -f5)

	getRepoTags "$REGISTRY" $REPO | while read tag; do
		url=$(python3 "$GUFD_PY" $DIGEST < <(getManifest "$REGISTRY" $REPO $tag))
		if [ $url ]; then
			echo "fetching layer from: $url/$DIGEST"
			getLayer "$url/$DIGEST" > "$DIR/$DIGEST"
			
			break
		fi
	done
	
	shift
done
