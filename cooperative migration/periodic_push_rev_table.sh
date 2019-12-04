#!/bin/bash

# $1 := <REGISTRY>
# $2 := <PERIOD>
# $3 := <ENDPOINT_1>
# ...
# $N := <ENDPOINT_(N-2)>

if [ $# -lt 3 ]; then
	echo "Usage: $0 REGISTRY PERIOD ENDPOINT [ENDPOINTs...]"
	exit 1
fi

REGISTRY=$1
PERIOD=$2
shift
shift

ENDPOINTS=()
while (( $# )); do
	ENDPOINTS+=($1)
	shift
done

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

get_layers_urls () {
	curl -Ss $1/v2/$2/manifests/$3 \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json" | python3 -c "
import sys, json;
for l in json.load(sys.stdin)['layers']:
	print(l['digest'], ' ', *l['urls'] if 'urls' in l else '')"
}

layer_json_obj () {
	# <digest> <url> ...
	echo "{"
	echo "\"digest\": \"$1\","
	echo '"urls": ['
	
	shift
	i=0
	while (($#)); do
		if [ $i -gt 0 ]; then
			echo -n ","
		fi
		echo -n "\"$1\""
		i=$((i+1))
		shift
	done

	echo ']}'
}


TABLE_FILE="reverse_table.tmp"

echo "Next periodic push in $PERIOD seconds ..."
while sleep $PERIOD; do
	# scan local Registry and build reverse table
	echo '{"layers": [' > "$TABLE_FILE" 	# trunc
	for REPO in $(get_repos $REGISTRY); do
		for TAG in $(get_tags $REGISTRY $REPO); do
			for LAYER_URLS in $(get_layers_urls $REGISTRY $REPO $TAG); do
				layer_json_obj $LAYER_URLS "$REGISTRY/v2/$REPO/blobs" # <- itself
				echo ','
			done
		done
	done >> "$TABLE_FILE"
	# after the final ,
	layer_json_obj "EndOfTable" "" >> "$TABLE_FILE"
	echo ']}' >> "$TABLE_FILE"
	
	# send reverse table to all endpoints
	for ENDPOINT in ${ENDPOINTS[@]}; do
		curl -v "$ENDPOINT" --data @"$TABLE_FILE" # -X POST # POST is already inferred
	done
	
	echo "Next periodic push in $PERIOD seconds ..."
done
