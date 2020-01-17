#!/bin/bash

# $1 := SOURCE
# $2 := TAR_FILE
# $3 := TARGET_DIR
# $4 := SRC_CONTAINER
# $5 := CONTAINER
# [$6 := USER]

if [ $# -lt 5 ] || [ $# -gt 6 ]; then
	echo "Usage: $0 SOURCE TAR_FILE TARGET_DIR SRC_CONTAINER CONTAINER [USER]"
	exit 1
fi

SOURCE=$1
TAR_FILE="$2"
TARGET_DIR="$3"
SRC_CONTAINER=$4
CONTAINER=$5

USER="" 	# no need if all nodes have the same user name
if [ $# -ge 6 ]; then
	USER="$6@"
fi

mkdir -p "$TARGET_DIR"

# move the backup to the destination
echo "Copying ($SOURCE) $TAR_FILE to $TARGET_DIR ..."
scp $USER$SOURCE:"$TAR_FILE" "$TARGET_DIR"

# extract it into the container's root
docker exec -i $CONTAINER bash -c 'tar xPvf - -C /' < "$TARGET_DIR"/"$TAR_FILE"

# delete 'D' files and directories
ssh $USER$SOURCE "docker diff $SRC_CONTAINER" | while read type path; do
	if [ "$type" = "D" ]; then
		echo $path
	fi
done | docker exec -i $CONTAINER bash -c 'while read line; do rm -rv "$line"; done'

# clean up
# rm "$TARGET_DIR"/"$TAR_FILE"
