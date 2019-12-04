#!/bin/bash

# $1 := <REGISTRY>

if [ $# -ne 1 ]; then
	echo "Usage: $0 REGISTRY"
	exit 1
fi

REGISTRY=$1

CURR_DIR=$(dirname "$0")

get_repos () {
	curl -Ss $1/v2/_catalog | python3 -c "
import sys, json;
for r in json.load(sys.stdin)['repositories']:
	print(r)"
}

get_tags () {
	curl -Ss $1/v2/$2/tags/list | python3 -c "
import sys, json;
for t in json.load(sys.stdin)['tags']:
	print(t)"
}

DIGESTS=()
URLS=()

while read digest urls; do
	echo $digest $urls
	if [ "$digest" = "EndOfTable" ]; then
		for REPO in $(get_repos $REGISTRY); do
			for TAG in $(get_tags $REGISTRY $REPO); do
				MANIFEST_FILE="$(echo $REPO | sed 's/\//./g').$TAG.mnf"
				# TODO: remove prev. files
				
				curl -Ss $REGISTRY/v2/$REPO/manifests/$TAG \
					-o "$MANIFEST_FILE" \
					-H "Accept: application/vnd.docker.distribution.manifest.v2+json"
				
				echo "inspecting $MANIFEST_FILE"
				I=0
				for DIGEST in ${DIGESTS[@]}; do
					if grep -q "$DIGEST" "$MANIFEST_FILE"; then
						URL=${URLS[$I]}
						echo "found $DIGEST (urls=$URL)"
						python3 $CURR_DIR/update_manifest.py $DIGEST $URL > "${MANIFEST_FILE}.out" < "$MANIFEST_FILE"
						cp "${MANIFEST_FILE}.out" "$MANIFEST_FILE"
					fi
					
					I=$((I+1))
				done
				
				curl -v $REGISTRY/v2/$REPO/manifests/$TAG \
					-X PUT \
					-H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" \
					--data @"$MANIFEST_FILE"
			done
		done
	
		# clear arrays for next cycle
		DIGESTS=()
		URLS=()
	elif [[ "$digest" =~ ^sha ]]; then # check that it is not a debug line
		DIGESTS+=($digest)
		URLS+=($urls)
	fi
done
