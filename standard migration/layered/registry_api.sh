#!/bin/bash

# curl -s (silent, suppress progress bar) -S (show error, if present)

IMPORT="import sys, json;" # parsing JSON with python3 (json module)

if [ $# -eq 1 ]; then
	# $1 := <REGISTRY_ADDR>
	curl -Ss $1/v2/_catalog | python3 -c "
$IMPORT
for r in json.load(sys.stdin)['repositories']:
	 print(r)
"

elif [ $# -eq 2 ]; then
	# $2 := <REPO>
	curl -Ss $1/v2/$2/tags/list | python3 -c "
$IMPORT
for t in json.load(sys.stdin)['tags']:
	print(t)
"

elif [ $# -eq 3 ]; then
	# $3 := <TAG>
	curl -Ss $1/v2/$2/manifests/$3 \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json" | python3 -c "
$IMPORT
for l in json.load(sys.stdin)['layers']:
	print(l['digest'])
"

elif [ $# -eq 4 ] && [ $4 = "config" ]; then
	# $4 := config
	curl -Ss $1/v2/$2/manifests/$3 \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json" | python3 -c "$IMPORT print(json.load(sys.stdin)['config']['digest'])"

else
	SHNAME=$(basename "$0")
	COMMON="$SHNAME <REGISTRY_ADDR>"
	echo "Usage:"
	echo -e "$COMMON \n\t list repositories"
	echo -e "$COMMON <REPO> \n\t list tags"
	echo -e "$COMMON <REPO> <TAG> \n\t get layers' digests"
	echo -e "$COMMON <REPO> <TAG> config \n\t get config digest"
fi
