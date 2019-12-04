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

get_layers () {
	curl -Ss $1/v2/$2/manifests/$3 \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json" | python3 -c "
import sys, json;
for l in json.load(sys.stdin)['layers']:
	print(l['digest'])"
}

notification_event () {
	# <action> <method> <repository> <digest> <url> [<tag>]
	echo "{"
	echo "\"timestamp\": \"$(date)\","
	echo "\"action\": \"$1\","
	echo '"source": {"instanceID": "","addr": ""},'
	echo '"id": "",'
	echo '"request": {'
	echo "\"method\": \"$2\","
	echo '"id": "","useragent": "","host": "","addr": ""},'
	echo '"target": {'
	echo "\"digest\": \"$4\","
	echo '"length": "","size": "",'
	echo "\"url\": \"$5\","
	echo "\"repository\": \"$3\","
	if [ $# -eq 6 ]; then
		echo "\"tag\": \"$6\","
		echo '"mediaType": "application/vnd.docker.distribution.manifest.v2+json"'
	else
		echo '"mediaType": "application/octet-stream"'
	fi
	echo '}, "actor": {}'
	echo "}"
}


ENV_FILE="envelope.tmp"

echo "Next periodic push in $PERIOD seconds ..."
while sleep $PERIOD; do
	# scan local Registry and build envelope
	echo '{"events": [' > "$ENV_FILE" 	# trunc
	for REPO in $(get_repos $REGISTRY); do
		for TAG in $(get_tags $REGISTRY $REPO); do
			for LAYER in $(get_layers $REGISTRY $REPO $TAG); do
				notification_event "push" "PUT" "$REPO" "$LAYER" "$REGISTRY/v2/$REPO/blobs/$LAYER"
				echo ','
			done
		done
	done >> "$ENV_FILE"
	# after the final ,
	notification_event "pull" "GET" "EndOfEnvelope" "" "" >> "$ENV_FILE"
	echo ']}' >> "$ENV_FILE"
	
	# send envelope to all endpoints
	for ENDPOINT in ${ENDPOINTS[@]}; do
		curl -v "$ENDPOINT" --data @"$ENV_FILE" # -X POST # POST is already inferred
	done
	
	echo "Next periodic push in $PERIOD seconds ..."
done
