#!/bin/bash

# push a config blob

# $1 := <DIGEST>
# $2 := <LEN>
# $3 := <UPLOAD_URL>
# $4 := <FROM_FILE>

DIGEST="$1"
LEN=$2
UPLOAD_URL="$3"
FROM_FILE="$4"

UPLOAD_URL=${UPLOAD_URL%$'\r'} # remove Win CR
DIGEST=${DIGEST%$'\r'} # remove Win CR

SYMBOL="?"
if [[ $UPLOAD_URL =~ "?" ]]; then
	SYMBOL="&"
fi

curl -v "${UPLOAD_URL}${SYMBOL}digest=${DIGEST}" \
	-X PUT \
	-H "Content-Length: $LEN" \
	-H "Range: 0-$LEN" \
	-H "Content-Type: application/octet-stream" \
	--data @"$FROM_FILE"
