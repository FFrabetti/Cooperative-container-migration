#!/bin/bash

# $1 := <CONTAINER>
# $2 := <SCRIPT>

if [ $# -ne 2 ]; then
	echo "Usage: $0 CONTAINER SCRIPT"
	exit 1
fi

CONTAINER=$1
SCRIPT="$2"

docker container inspect --format='{{range $m := .Mounts}}
{{if eq $m.Type "volume"}} {{$m.Name}} {{$m.Destination}} {{end}}
{{end}}' $CONTAINER | docker run \
	--rm --volumes-from $CONTAINER:ro \
	-v $(pwd)/backup:/backup \
	-v $(pwd)/"$SCRIPT":/"$SCRIPT" \
	-a stdin -a stdout -i \
	ubuntu /"$SCRIPT"
