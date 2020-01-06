#!/bin/bash
# Traditional Stateful Migration - to be executed at the destination

# $1 := <SOURCE>
# $2 := <CONTAINER>
# $3 := [<REGISTRY_TAG>]

SOURCE=$1
CONTAINER=$2
REGISTRY_TAG=$3 	# if not given, try to use $SOURCE/$IMAGE

# given a container, find out which image it is using
IMAGE=$(ssh $SOURCE "docker container inspect $CONTAINER -f '{{.Config.Image}}'")
IMAGE=$(echo $IMAGE | cut -d/ -f2)
IMAGE_REPO=$(echo $IMAGE | cut -d: -f1)
IMAGE_TAG=$(echo $IMAGE | cut -d: -f2)

if [ $# -lt 3 ]; then
	REGISTRY_TAG="$SOURCE/$IMAGE"
fi


# -------------------------------- FUNCTIONS --------------------------------
function error_exit {
	errMsg="$@"
	if [ $# -eq 0 ]; then
		errMsg="unspecified terminating error"
	fi
	echo "Error: $errMsg"
	exit 1
}

function curl_test_ok {
	# -s silent, -L follow redirects, -I HEAD, -w custom output format, -o redirect HTML
	# see also: --connect-timeout <CT>, --max-time <MT>
	[ $(curl -sLI -w '%{http_code}' "$1" -o /dev/null) == "200" ]
}

function b64url_encode {
	python3 -c "import base64; print(base64.urlsafe_b64encode(\"$1\".encode()).decode())"
}

function b64url_decode {
	python3 -c "import base64; print(base64.urlsafe_b64decode(\"$1\".encode()).decode())"
}

function rsyncFrom {
	OPTIONS="-aczv" 	# archive, checksum (not mod-time & size), compress, verbose
	if [ $# -eq 4 ]; then
		OPTIONS=$4
	fi
	
	# pull from SOURCE ($1)
	rsync $OPTIONS $1:"$2" "$3"
}

function get_label_value {
	[[ "$2" =~ (=|,)$1=([^,]+)(,|$) ]] && echo ${BASH_REMATCH[2]}
}
# ----------------------------------------------------------------


# -------------------------------- SETUP --------------------------------
# set PATH so to find other scripts in the same dir
OLD_PATH=$PATH 	# just in case I ever need the original PATH
DIR=$(dirname "$0")
PATH="$PATH:$DIR"

# ################ SECURITY ALERT ################
# [ $EUID -eq 0 ] to check if root
if [ -f "psw.insecure" ]; then
	PASSWD=$(cat "psw.insecure")
else
	error_exit "psw.insecure required"
fi
# ################ SECURITY ALERT ################

if [ -f "debug.mode" ]; then
	DEBUG_MODE="true"
	echo "Setting DEBUG_MODE=$DEBUG_MODE"
fi

RW_GUID_KEY="rw-guid" 				# key for custom volume label with the GUID for rw

VOL_LIST="volumes.list" 			# file with volumes metadata
VOL_ARCHIVES="/volume_archives" 	# dir with all volume archives
VOL_BACKUPS="backup"				# dir with volume backups for current migration
CHECKPT_DIR="checkpoint"			# dir with checkpoint for current migration

REMOTE_SH_DIR="\$HOME/bin"							# search scripts in remote $HOME/bin
REMOTE_VOL_BACKUPS="\$HOME/$CONTAINER/backup" 		# remote dir for volume backups
REMOTE_CHECKPT_DIR="\$HOME/$CONTAINER/checkpoint"	# remote dir for checkpoint files

[[ ! -d "$VOL_ARCHIVES" || ! -w "$VOL_ARCHIVES" ]] && error_exit "cannot write to $VOL_ARCHIVES"

# move to a unique working directory (for multiple migrations at the same time)
UUID=$$ 	# PID
while [ -e $UUID ]; do
	UUID=$(cat /proc/sys/kernel/random/uuid)
done
WORKDIR=$UUID
! mkdir $WORKDIR || ! cd $WORKDIR && error_exit "try again"

echo "Directory changed to: $(pwd)"
# ----------------------------------------------------------------


# 2.1 transfer container image
docker pull $REGISTRY_TAG || error_exit "container image not found $REGISTRY_TAG"
# push to local registry (for distributed version only)
if [ $# -lt 3 ]; then
	for ip in $(hostname -I); do
		if curl_test_ok "https://$ip/v2/"; then
			LOCAL_REGISTRY=$ip
			docker tag $REGISTRY_TAG "$LOCAL_REGISTRY/$IMAGE"
			docker push "$LOCAL_REGISTRY/$IMAGE"
		fi
	done
fi

# 2.2 transfer volumes
# get volumes list
ssh $SOURCE "$REMOTE_SH_DIR/get_volumes_list.sh $CONTAINER" > "$VOL_LIST"

# filter read-only volumes already present at the destination
# and run utility container (at the source) to backup the content of the others
mkdir "$VOL_BACKUPS" 	# dir for volume archives
while read name destination rw labels options; do
	if [ $rw = "true" ]; then
		echo $name "$destination" 	# rw volumes have to be sent for sure
		
		rw_guid=$(get_label_value "$RW_GUID_KEY" "$labels")
		archpath="$VOL_ARCHIVES/rw.${rw_guid}.tar"
		if [ $rw_guid ] && [ -e "$archpath" ]; then
			cp "$archpath" "$VOL_BACKUPS/$name.tar"
		fi		
	else
		ro_guid=$(b64url_encode "$IMAGE$destination")
		archpath="$VOL_ARCHIVES/ro.${ro_guid}.tar"
		if [ ! -e "$archpath" ]; then
			echo $name "$destination" 	# ro volumes not already in $VOL_ARCHIVES
		else
			cp "$archpath" "$VOL_BACKUPS/$name.tar"
		fi
	fi
done < "$VOL_LIST" | ssh $SOURCE "$REMOTE_SH_DIR/run_utilc_voltotar.sh $CONTAINER $REMOTE_VOL_BACKUPS"

# rsync volume archives
rsyncFrom $SOURCE "$REMOTE_VOL_BACKUPS/" "$VOL_BACKUPS"

# run utility container to create the volumes and extract the content of the archives
VOLNAMES=()
VOLNAMES_RO=()
MOUNTSTR=""
MOUNTSTR_RO=""
while read name destination rw labels options; do
	MOUNT="--mount type=volume,dst=$destination"
	# if there are no labels, then $labels contains options, but that is ok
	if [ $labels ]; then
		labels=$(echo $labels | rev | cut -c 2- | rev) 	# no trailing ,
		MOUNT="$MOUNT,$labels"
	fi
	if [ $options ]; then
		options=$(echo $options | rev | cut -c 2- | rev) 	# no trailing ,
		MOUNT="$MOUNT,$options"
	fi
	
	if [ $rw = "true" ]; then
		MOUNTSTR="$MOUNTSTR $MOUNT"
		VOLNAMES+=($name)
	else
		MOUNTSTR_RO="$MOUNTSTR_RO $MOUNT"
		VOLNAMES_RO+=($name)
	fi
done < "$VOL_LIST"

# debug
echo "Mounting (RW): $MOUNTSTR"
echo "Mounting (RO): $MOUNTSTR_RO"
# echo ${VOLNAMES[@]}
# echo ${VOLNAMES_RO[@]}

TAR_TO_VOL=$(which tar_to_vol.sh) 	# absolute path
UCONT_ID=$(docker run -d \
	-v "$(pwd)/$VOL_BACKUPS":/backup \
	-v "$TAR_TO_VOL":/tar_to_vol.sh \
	$MOUNTSTR ubuntu /tar_to_vol.sh ${VOLNAMES[@]})
UCONT_ID_RO=$(docker run -d \
	-v "$(pwd)/$VOL_BACKUPS":/backup \
	-v "$TAR_TO_VOL":/tar_to_vol.sh \
	$MOUNTSTR_RO ubuntu /tar_to_vol.sh ${VOLNAMES_RO[@]})

# 2.3 transfer checkpoint
# leave running
CHECKPOINT=$(date +%F_%H-%M-%S) 	# (e.g. 2020-01-06_08-09-15)

# ################ SECURITY ALERT ################
echo "$PASSWD" | ssh -tt $SOURCE "$REMOTE_SH_DIR/criu_checkpoint.sh $CONTAINER $CHECKPOINT $REMOTE_CHECKPT_DIR"
# ################ SECURITY ALERT ################

scp $SOURCE:"$REMOTE_CHECKPT_DIR/$CONTAINER.$CHECKPOINT.tar" ./ || error_exit "scp"
mkdir -p "$CHECKPT_DIR"
tar xf "$CONTAINER.$CHECKPOINT.tar" -C "$CHECKPT_DIR"

TARGET_CONTAINER=$(docker create \
	--volumes-from $UCONT_ID \
	--volumes-from $UCONT_ID_RO:ro \
	$REGISTRY_TAG) 	# use pulled image

if [ $DEBUG_MODE ]; then
	echo "Debug mode ON: waiting a few seconds..."
	sleep 5
fi

# 3. stop container and 4.1 send checkpoint difference
CHECKPOINT_F="${CHECKPOINT}-final"
ssh $SOURCE "docker checkpoint create $CONTAINER $CHECKPOINT_F --checkpoint-dir=\"$REMOTE_CHECKPT_DIR\""

# ################ SECURITY ALERT ################
echo "$PASSWD" | ssh -tt $SOURCE "sudo chown \$USER $REMOTE_CHECKPT_DIR/$CHECKPOINT_F"
# ################ SECURITY ALERT ################

rsyncFrom $SOURCE "$REMOTE_CHECKPT_DIR/$CHECKPOINT_F/" "$CHECKPT_DIR" "-acz --delete" || error_exit "final checkpoint rsync"
sudo cp -r "$CHECKPT_DIR/" "/var/lib/docker/containers/$TARGET_CONTAINER/checkpoints/$CHECKPOINT_F"

# 4.2 sync writable volumes content
while read name destination rw rest; do
	if [ $rw = "true" ]; then
		echo $name "$destination"
	fi
done < "$VOL_LIST" | ssh $SOURCE "$REMOTE_SH_DIR/run_utilc_voltotar.sh $CONTAINER $REMOTE_VOL_BACKUPS"
CHANGED_VOLS=$(rsyncFrom $SOURCE "$REMOTE_VOL_BACKUPS/" "$VOL_BACKUPS" "-acz --out-format=%n")

# debug
echo "CHANGED_VOLS=$CHANGED_VOLS"

# wait for termination
docker container wait $UCONT_ID $UCONT_ID_RO

# if [ $DEBUG_MODE ]; then
	# docker logs $UCONT_ID 		2>&1 > ucont.logs
	# docker logs $UCONT_ID_RO 		2>&1 > ucontro.logs
# fi

docker run \
	--volumes-from $UCONT_ID \
	-v "$(pwd)/$VOL_BACKUPS":/backup \
	-v "$TAR_TO_VOL":/tar_to_vol.sh \
	ubuntu /tar_to_vol.sh $CHANGED_VOLS

# 5. start target container from checkpoint
docker start --checkpoint=$CHECKPOINT_F $TARGET_CONTAINER && echo -e '\n\nSUCCESS!\nStarted container:' "$TARGET_CONTAINER"


# -------------------------------- CLEAN UP --------------------------------
# sync local repo dir ($VOL_ARCHIVES) with all volume archives
# we need to rename them first
while read name dest rw labels rest; do
	archfile="$VOL_BACKUPS/$name.tar"
	if [ -f "$archfile" ]; then
		echo "found file: $archfile"
		if [ $rw = "true" ]; then
			rw_guid=$(get_label_value "$RW_GUID_KEY" "$labels")
			echo "it is RW, with guid: $rw_guid"
			if [ $rw_guid ]; then
				mv "$archfile" "$VOL_BACKUPS/rw.${rw_guid}.tar"
			else
				echo "No guid for $archfile"
				rm "$archfile"
			fi
		else
			ro_guid=$(b64url_encode "$IMAGE$dest")
			echo "it is RO, with guid: $ro_guid"
			mv "$archfile" "$VOL_BACKUPS/ro.${ro_guid}.tar"
		fi
	fi
done < "$VOL_LIST"
rsync -acv "$VOL_BACKUPS/" "$VOL_ARCHIVES"

if [ ! $DEBUG_MODE ]; then
	cd ..
	rm -rv $WORKDIR
fi

# remove remote dir ???
