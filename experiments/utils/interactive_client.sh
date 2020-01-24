#!/bin/bash

# Processing times are read from file (generated once for traditional and cooperative experiments)

RESPONSE_SIZE=$1
PR_FILE="$2"

while [ -f "$PR_FILE" ]; do
	while read pt; do
		echo "$pt $RESPONSE_SIZE"
		sleep 1
	done < "$PR_FILE"
done 
