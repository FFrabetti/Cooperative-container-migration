#!/bin/bash

# push an image layer
# https://docs.docker.com/registry/spec/api/#pushing-an-image

# $1 := <REGISTRY>
# $2 := <REPOSITORY>
# $3 := <DIGEST>
# $4 := <FROM_REPO>

# $4 := <LEN>
# $5 := <UPLOAD_URL>
# $6 := <FROM_FILE>

if [ $# -ne 4 ] && [ $# -ne 6 ]; then
	echo -n "Usage: $(basename $0) <REGISTRY> <REPOSITORY> <DIGEST> "
	echo "(<FROM_REPO>|<LEN> <UPLOAD_URL> <FROM_FILE>)"
	exit 1
fi

REGISTRY=$1
REPO=$2
DIGEST=$3

DIGEST=${DIGEST%$'\r'} # remove Win CR

if [ $# -eq 6 ]; then	# monolithic upload
	LEN=$4
	UPLOAD_URL="$5"
	FROM_FILE="$6"
	
	UPLOAD_URL=${UPLOAD_URL%$'\r'} # remove Win CR

	SYMBOL="?"
	if [[ $UPLOAD_URL =~ "?" ]]; then
		SYMBOL="&"
	fi
	URL="${UPLOAD_URL}${SYMBOL}digest=${DIGEST}"

	curl -v "$URL" \
		-X PUT \
		-H "Content-Length: $LEN" \
		-H "Range: 0-$LEN" \
		-H "Content-Type: application/octet-stream" \
		--data-binary @"$FROM_FILE"		# @filename
	
	# 201 Created response
	# - Location: registry URL to access the accepted layer file
	# - Docker-Content-Digest: canonical digest of the uploaded blob, which may differ from the provided digest

else	# cross repository blob mount
	FROM_REPO=$4
	curl -v "$REGISTRY/v2/$REPO/blobs/uploads/?mount=$DIGEST&from=$FROM_REPO" \
		-I -X POST \
		-H "Content-Length: 0"

	# If a mount fails (invalid repository or digest), fall back to the standard upload behavior: 202 Accepted and upload URL in the Location header
fi

# check layer presence
if [ -f ./test_layer.sh ]; then
	if ./test_layer.sh $REGISTRY $REPO $DIGEST; then
		echo "Layer successfully uploaded!"
	else
		echo "ERROR: layer not found"
	fi
fi


# delete a layer (deletion must be enabled on the registry)
# curl -v $REGISTRY/v2/$REPO/blobs/$DIGEST -X DELETE
