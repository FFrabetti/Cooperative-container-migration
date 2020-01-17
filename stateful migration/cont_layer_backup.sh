#!/bin/bash

# $1 := CONTAINER

if [ $# -ne 1 ]; then
	echo "Usage: $0 CONTAINER"
	exit 1
fi

CONTAINER=$1

# docker exec -it -e VAR="$LIST" $CONTAINER bash -c 'echo $VAR'

# NOTE: the content of volumes is not included in the output of docker diff, but the directories in which they are mounted are (A)
# : separated list of volume mount points
VOLUMES=$(docker container inspect $CONTAINER --format=':{{range $m := .Mounts}}{{$m.Destination}}:{{end}}')
# haystack="foo:bar" and [[ ":$haystack:" = *:$needle:* ]]

# directories with new/deleted files (A/D) are included as C
# C /dir
# D /dir/whatever
# for each type C, if next is subpath then skip
# -> keep C on hold, if next is not subpath then print it

# for A directories, we can skip all their content (all A)
# for each type A, if is subpath of the last A then skip

LAST_C=""
LAST_A="/"
docker diff $CONTAINER | while read type path; do
	if [ "$LAST_C" ]; then # there is one saved
		if [[ ! "$path" = "$LAST_C"/* ]]; then
			echo $LAST_C
			# else: skip C directory
		fi
		LAST_C="" # clear
	fi

	if ([ "$type" = "A" ] || [ "$type" = "C" ]) && [[ ! "$VOLUMES" = *:"$path":* ]]; then
		if [ "$type" = "C" ]; then
			LAST_C="$path"
		elif [ "$type" = "A" ] && [[ ! "$path" = "$LAST_A"/* ]]; then
			LAST_A="$path" # update LAST_A
			echo $path
		# else (A and subpath): skip/noop
		fi
	fi
done | docker exec -i $CONTAINER bash -c 'tar cPv -T -' 	# > archfile.tar
# -T, --files-from
# -P, --absolute-names

# --------------------------------
# ... bash -c 'tar cPvf cont_layer.tar -T -'

# container paths are relative to the container’s / (root) directory
# local machine’s relative paths are relative to the current working directory
# docker cp $CONTAINER:"cont_layer.tar" ./

# debug
# tar tPf "cont_layer.tar"
