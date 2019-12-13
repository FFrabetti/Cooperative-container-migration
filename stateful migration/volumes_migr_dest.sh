#!/bin/bash

# $1 := SOURCE
# $2 := BACKUP_DIR
# $3 := TARGET_DIR (absolute)
# $4 := SCRIPT
# $5 := CONT_IMAGE
# [$6 := USER]

if [ $# -lt 5 ] || [ $# -gt 6 ]; then
	echo "Usage: $0 SOURCE BACKUP_DIR TARGET_DIR SCRIPT CONT_IMAGE [USER]"
	exit 1
fi

SOURCE=$1
BACKUP_DIR="$2"
TARGET_DIR="$3"
SCRIPT="$4"
CONT_IMAGE=$5

# or: ls .../*.tar
SSH_CMD="if [ -f $BACKUP_DIR ]; then cat $BACKUP_DIR; else ls -1 $BACKUP_DIR/*; fi"
# ls -1 	list one file per line

USER="" 	# no need if all nodes have the same user name
if [ $# -ge 6 ]; then
	USER="$6@"
fi

mkdir -p "$TARGET_DIR"

# 3. Move the backups to the destination
ssh $USER$SOURCE "$SSH_CMD" | while read line; do
	echo "Copying ($SOURCE) $line to $TARGET_DIR ..."
	scp $USER$SOURCE:$line "$TARGET_DIR" && echo "$line ... ok"
done

# 4. Extract them into corresponding new volumes
MOUNTSTR=""
for arch in "$TARGET_DIR"/*.tar; do
	MOUNTSTR="$MOUNTSTR --mount type=volume,dst=$(tar -tPf $arch | head -1)"
done

# debug
echo "Using: $MOUNTSTR"
# for output on screen: -a stdout -i
CONT_ID=$(docker run -d \
	-v "$TARGET_DIR":/backup \
	-v $(pwd)/"$SCRIPT":/"$SCRIPT" \
	$MOUNTSTR ubuntu /"$SCRIPT")

# 5. Mount the volumes into the target container
docker run -d --volumes-from $CONT_ID --name test_vol_migr $CONT_IMAGE

# docker exec -it test_vol_migr bash
# ls...
