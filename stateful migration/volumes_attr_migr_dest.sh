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
VOLNAMES=()
VOLNAMES_RO=()
MOUNTSTR=""
MOUNTSTR_RO=""
for list in "$TARGET_DIR"/*.list; do
	while read name destination rw labels options; do
		MOUNT="--mount type=volume,dst=$destination"
		# if there are no labels, then $labels contains options, but that is ok
		if [ $labels ]; then
			labels=$(echo $labels | rev | cut -c 2- | rev)
			MOUNT="$MOUNT,$labels"
		fi
		if [ $options ]; then
			options=$(echo $options | rev | cut -c 2- | rev)
			MOUNT="$MOUNT,$options"
		fi
		
		if [ $rw = "true" ]; then
			MOUNTSTR="$MOUNTSTR $MOUNT"
			VOLNAMES+=($name)
		else
			MOUNTSTR_RO="$MOUNTSTR_RO $MOUNT"
			VOLNAMES_RO+=($name)
		fi
	done < "$list"
done

# debug
echo "Using (RW): $MOUNTSTR"
echo "Using (readonly): $MOUNTSTR_RO"

echo ${VOLNAMES[@]}
echo ${VOLNAMES_RO[@]}

CONT_ID=$(docker run -d \
	-v "$TARGET_DIR":/backup \
	-v $(pwd)/"$SCRIPT":/"$SCRIPT" \
	$MOUNTSTR ubuntu /"$SCRIPT" ${VOLNAMES[@]})
CONT_ID_RO=$(docker run -d \
	-v "$TARGET_DIR":/backup \
	-v $(pwd)/"$SCRIPT":/"$SCRIPT" \
	$MOUNTSTR_RO ubuntu /"$SCRIPT" ${VOLNAMES_RO[@]})

# TODO: wait for termination of CONT_ID and CONT_ID_RO
# 		or remove -d and get their names/IDs

# 5. Mount the volumes into the target container
docker run -d \
	--volumes-from $CONT_ID \
	--volumes-from $CONT_ID_RO:ro \
	--name test_vol_migr $CONT_IMAGE

# docker exec -it test_vol_migr bash
# ls...
