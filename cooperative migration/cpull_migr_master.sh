#!/bin/bash
# Centralized Pull-based migration - to be executed at the master

# NOTE: a Registry has to be running at $1
# curl -v $1/v2/

# $1 := <REGISTRY>
# $2 := <PERIOD>
# $3 := <WORK_DIR>
# $4 := <NODE_1>
# ...
# [$N := <NODE_(N-3)>]

if [ $# -lt 4 ]; then
	echo "Usage: $0 REGISTRY PERIOD WORK_DIR NODE [NODEs...]"
	exit 1
fi

REGISTRY=$1
PERIOD=$2
WORK_DIR=$3

shift
shift
shift

NODES=()
while (( $# )); do
	NODES+=($1)
	shift
done

# number of nodes
# echo ${#NODES[@]}
# for N in ${NODES[@]}; do ... done

# set PATH so to find other scripts in the same dir
TMP_PATH=$PATH 	# just in case I ever need the original PATH
DIR=$(dirname "$0")
PATH="$PATH:$DIR"

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

get_layers () {
	curl -Ss $1/v2/$2/manifests/$3 \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json" | python3 -c "
import sys, json;
for l in json.load(sys.stdin)['layers']:
	print(l['digest'])"
}


# periodically request to all nodes their manifests (for each repository)
# from each of which you can get a list of layers (digests)
echo "Next periodic request in $PERIOD seconds ..."
while sleep $PERIOD; do
	rm $WORK_DIR/*
	
	for NODE in ${NODES[@]}; do
		for REPO in $(get_repos $NODE); do
			for TAG in $(get_tags $NODE $REPO); do
				for LAYER in $(get_layers $NODE $REPO $TAG); do
					
					FILE_NAME="$WORK_DIR/${LAYER}.txt"
					LINE="$NODE/v2/$REPO/blobs"
					
					if [ ! -f "$FILE_NAME" ] || ! grep -q "^${LINE}$" "$FILE_NAME"; then
						#echo "$LINE | $LAYER" # debug
						echo "$LINE" >> "$FILE_NAME"
					fi
				done
			done
		done
	done
	
	# update its Registry with the list of URLs
	for REPO in $(get_repos $REGISTRY); do
		for TAG in $(get_tags $REGISTRY $REPO); do
			# get manifest
			MANIFEST_FILE="$WORK_DIR/$(echo $REPO | sed 's/\//./g').$TAG.mnf"
			curl -Ss $REGISTRY/v2/$REPO/manifests/$TAG \
				-o "$MANIFEST_FILE" \
				-H "Accept: application/vnd.docker.distribution.manifest.v2+json"
			
			echo "Updating $MANIFEST_FILE"
						
			# for each layer, set field urls
			cat "$MANIFEST_FILE" | python3 $DIR/update_manifest_urls.py "$WORK_DIR" > "${MANIFEST_FILE}.out"
			
			# upload updated manifest
			curl -v $REGISTRY/v2/$REPO/manifests/$TAG \
				-X PUT \
				-H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" \
				--data @"${MANIFEST_FILE}.out"
		done
	done
	echo "Next periodic request in $PERIOD seconds ..."
done
