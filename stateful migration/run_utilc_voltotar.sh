#!/bin/bash

CONTAINER=$1
BACKUP_DIR="/backup/$CONTAINER"

if [ $# -eq 2 ]; then
	BACKUP_DIR="$2"
fi

mkdir -p "$BACKUP_DIR"

docker run --rm \
	--volumes-from $CONTAINER:ro \
	-v "$BACKUP_DIR":/backup \
	-a stdin -a stdout -i \
	ubuntu bash -c 'while read vname vpath rest; do tar -cPvf "/backup/$vname.tar" $vpath; done'
