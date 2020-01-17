#!/bin/bash

# $1 := CONTAINER
# $2 := SCRIPT
# [$3 := BACKUP_DIR]

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
	echo "Usage: $0 CONTAINER SCRIPT [BACKUP_DIR]"
	exit 1
fi

CONTAINER=$1
SCRIPT="$2"
BACKUP_DIR="backup"

if [ $# -eq 3 ]; then
	BACKUP_DIR="$3"
fi

mkdir -p "$BACKUP_DIR"

docker container inspect --format='{{range $m := .Mounts}}
{{if eq $m.Type "volume"}} {{$m.Name}} {{$m.Destination}} {{end}}
{{end}}' $CONTAINER | docker run \
	--rm --volumes-from $CONTAINER:ro \
	-v $(pwd)/"$BACKUP_DIR":/backup \
	-v $(pwd)/"$SCRIPT":/"$SCRIPT" \
	-a stdin -a stdout -i \
	ubuntu /"$SCRIPT"
