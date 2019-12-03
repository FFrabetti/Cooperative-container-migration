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

while read line; do
	echo $line
	if [[ "$line" =~ ^url ]]; then
		URL=$(echo $line | cut -d, -f1 | cut -d= -f2)
		DIGEST=$(echo $line | cut -d, -f2 | cut -d= -f2)
		
		echo "Update $DIGEST with $URL ..."
	
		for REPO in $(get_repos $REGISTRY); do
			for TAG in $(get_tags $REGISTRY $REPO); do
				MANIFEST_FILE="$(echo $REPO | sed 's/\//./g').$TAG.mnf"
				# TODO: remove prev. files
				
				curl -Ss $REGISTRY/v2/$REPO/manifests/$TAG \
					-o "$MANIFEST_FILE" \
					-H "Accept: application/vnd.docker.distribution.manifest.v2+json"
				
				echo "inspecting $MANIFEST_FILE"
				
				# update manifest just if there are any changes
				if python3 $CURR_DIR/update_manifest.py $DIGEST $URL > "${MANIFEST_FILE}.out" < "$MANIFEST_FILE"; then
					echo "$URL added in $REPO $TAG"
					curl -v $REGISTRY/v2/$REPO/manifests/$TAG \
						-X PUT \
						-H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" \
						--data @"${MANIFEST_FILE}.out"
				fi
			done
		done
	fi
done
