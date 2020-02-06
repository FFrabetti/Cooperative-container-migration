#!/bin/bash

REPO=$1
VERS=$2
MASTER=$3
SRC=$4
N1=$5
N2=$6

source registry-functions.sh
UPDATE_MNF_PY=$(which "update_manifest.py")


getManifest $MASTER $REPO $VERS > manifest

# priorities:
# $N1
# $N2
# $SRC

for d in $(getLayersDigests < manifest); do
	for reg in $N1 $N2 $SRC; do
		if curl_test_ok "$reg/v2/$REPO/blobs/$d"; then
			echo "Layer $d found in $reg"
			python3 "$UPDATE_MNF_PY" $d "$reg/v2/$REPO/blobs" > manifest2 < manifest
			mv manifest2 manifest
		fi
	done
done

pushManifest $MASTER $REPO $VERS < manifest
