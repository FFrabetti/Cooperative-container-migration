#!/bin/bash
# Cooperative Stateful Migration - to be executed at the destination

# $1 := <SOURCE>
# $2 := <CONTAINER>
# $3 := <USER_ID>
# $4 := [<REGISTRY>]
# $5 := [<REDIS_HOST>]

if [ $# -lt 3 ] || [ $# -gt 5 ]; then
	echo "Usage: $0 SOURCE CONTAINER USER_ID [REGISTRY] [REDIS_HOST]"
	exit 1
fi

SOURCE=$1
CONTAINER=$2
USER_ID=$3
# if not given, try to use local registries
REGISTRY=$4
REDIS_HOST=$5


# -------------------------------- FUNCTIONS --------------------------------
source $(dirname "$0")/redis-functions.sh

function fetchLayers { 	# (parallel)
	# TODO
	echo "fetchLayers"
}

function fetchVolume { 	# (parallel) RW and RO not already present
	local name="$1"
	local prefix="$2"
	local guid="$3"

	local neighbor=$(selectNeighborWithVol "$REDIS_HOST" "${prefix}:${guid}")
	[ $neighbor ] && scp $neighbor:"$VOL_ARCHIVES/${prefix}.${guid}.tar" "$VOL_BACKUPS/$name.tar"
} # then: sync (if no-one had them, transfer them entirely from the source)

function fetchCheckpt { 	# if not already present
	local image_tag="$1"
	local user_id="$2"
	
	local neighbor=$(selectNeighborWithCheckpt "$REDIS_HOST" "$image_tag" "$user_id")
	[ $neighbor ] && scp $neighbor:"$CHECKPT_ARCHIVES/$image_tag.tar" ./
} # then: sync (if no-one had it, transfer it entirely from the source)

function volumeSetNotEmpty { # NAME PREFIX GUID
	[ $(getSetSize "$REDIS_HOST" "$2:$3") -gt 0 ] 	# from redis-functions.sh
}

function error_exit {
	local errMsg="$@"
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
	local OPTIONS="-aczv" 	# archive, checksum (not mod-time & size), compress, verbose
	if [ $# -eq 4 ]; then
		OPTIONS=$4
	fi
	
	# pull from SOURCE ($1)
	rsync $OPTIONS $1:"$2" "$3"
}

function get_label_value {
	[[ "$2" =~ (=|,)$1=([^,]+)(,|$) ]] && echo ${BASH_REMATCH[2]}
}

function echoDebug {
	[ $DEBUG_MODE ] && echo -e "$@\n"
}
# ----------------------------------------------------------------


for ip in $(hostname -I); do
	if curl_test_ok "https://$ip/v2/"; then
		LOCAL_REGISTRY=$ip
	fi
done
[ $LOCAL_REGISTRY ] || error_exit "No local Registry found"

if [ $# -lt 4 ]; then
	REGISTRY=$LOCAL_REGISTRY
fi

if [ $# -lt 5 ]; then
	REDIS_HOST="127.0.0.1"
fi


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

VOL_LIST="volumes.list" 				# file with volumes metadata
VOL_ARCHIVES="/volume_archives" 		# dir with all volume archives
VOL_BACKUPS="backup"					# dir with volume backups for current migration
CHECKPT_ARCHIVES="/checkpt_archives" 	# dir with all checkpoint archives
CHECKPT_DIR="checkpoint"				# dir with checkpoint for current migration

REMOTE_SH_DIR="\$HOME/bin"							# search scripts in remote $HOME/bin
REMOTE_VOL_BACKUPS="\$HOME/$CONTAINER/backup" 		# remote dir for volume backups
REMOTE_CHECKPT_DIR="\$HOME/$CONTAINER/checkpoint"	# remote dir for checkpoint files

[[ ! -d "$VOL_ARCHIVES" || ! -w "$VOL_ARCHIVES" ]] && error_exit "cannot write to $VOL_ARCHIVES"

[[ ! -d "$CHECKPT_ARCHIVES" || ! -w "$CHECKPT_ARCHIVES" ]] && error_exit "cannot write to $CHECKPT_ARCHIVES"

# move to a unique working directory (for multiple migrations at the same time)
UUID=$$ 	# PID
while [ -e $UUID ]; do
	UUID=$(cat /proc/sys/kernel/random/uuid)
done
WORKDIR=$UUID
! mkdir $WORKDIR || ! cd $WORKDIR && error_exit "try again"

echoDebug "Directory changed to: $(pwd)"
# ----------------------------------------------------------------


# given a container, find out which image it is using
IMAGE_FULL=$(ssh $SOURCE "docker container inspect $CONTAINER -f '{{.Config.Image}}'")
IMAGE=$(echo $IMAGE_FULL | cut -d/ -f2)
IMAGE_REPO=$(echo $IMAGE | cut -d: -f1)
IMAGE_TAG=$(echo $IMAGE | cut -d: -f2)

# 2.1 transfer container image
# TODO: loop fetchLayers ... & 	# then wait
docker pull "$IMAGE_FULL" 	# just for now, pull it from the master

echoDebug "Fetched container image: $IMAGE_FULL"

# push to local registry
if [ ! "$REGISTRY" = "$LOCAL_REGISTRY" ]; then
	docker tag "$IMAGE_FULL" "$LOCAL_REGISTRY/$IMAGE"
	docker push "$LOCAL_REGISTRY/$IMAGE"
	
	echoDebug "Image pushed to $LOCAL_REGISTRY/$IMAGE"
fi

# 2.2 transfer volumes
# get volumes list
ssh $SOURCE "$REMOTE_SH_DIR/get_volumes_list.sh $CONTAINER" > "$VOL_LIST"

echoDebug "Volumes list written to: $VOL_LIST"

# filter read-only volumes already present at the destination
# and run utility container (at the source) to backup the content of the others
mkdir "$VOL_BACKUPS" 	# dir for volume archives
while read name destination rw labels options; do
	if [ $rw = "true" ]; then
		echo $name "$destination" 	# rw volumes have to be sent for sure
		
		rw_guid=$(get_label_value "$RW_GUID_KEY" "$labels")
		archpath="$VOL_ARCHIVES/rw.${rw_guid}.tar"
		[ $rw_guid ] || error_exit "Writable volume $name has no GUID"
		if [ -e "$archpath" ]; then
			cp "$archpath" "$VOL_BACKUPS/$name.tar"
		else
			fetchVolume "$name" "rw" "$rw_guid" & 	# background
		fi
	else
		ro_guid=$(b64url_encode "$IMAGE$destination")
		archpath="$VOL_ARCHIVES/ro.${ro_guid}.tar"
		if [ -e "$archpath" ]; then
			cp "$archpath" "$VOL_BACKUPS/$name.tar"
		else
			if volumeSetNotEmpty "$name" "ro" "$ro_guid"; then
				fetchVolume "$name" "ro" "$ro_guid" & 	# background
			else
				echo $name "$destination" 	# ro volumes not in any $VOL_ARCHIVES
			fi
		fi
	fi
done < "$VOL_LIST" | ssh $SOURCE "$REMOTE_SH_DIR/run_utilc_voltotar.sh $CONTAINER $REMOTE_VOL_BACKUPS"

echo "Wait for volumes fetching..."
wait

echoDebug "Content of $VOL_BACKUPS: $(ls -l "$VOL_BACKUPS")"

# rsync volume archives
rsyncFrom $SOURCE "$REMOTE_VOL_BACKUPS/" "$VOL_BACKUPS"

echoDebug "Content of $VOL_BACKUPS after sync: $(ls -l "$VOL_BACKUPS")"

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
echoDebug "Mounting (RW): $MOUNTSTR"
echoDebug "Mounting (RO): $MOUNTSTR_RO"
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
mkdir -p "$CHECKPT_DIR"

echoDebug "Trying to fetch checkpoint for $IMAGE $USER_ID..."
# --force local 	archive file is local even if it has a colon
fetchCheckpt "$IMAGE" "$USER_ID" && tar xf "$IMAGE.tar" --force-local -C "$CHECKPT_DIR"

echoDebug "Content of $(pwd): $(ls -l)"

# leave running
CHECKPOINT=$(date +%F_%H-%M-%S) 	# (e.g. 2020-01-06_08-09-15)
ssh $SOURCE "docker checkpoint create $CONTAINER $CHECKPOINT --checkpoint-dir=\"$REMOTE_CHECKPT_DIR\" --leave-running"

# ################ SECURITY ALERT ################
echo "$PASSWD" | ssh -tt $SOURCE "sudo chown -R \$USER $REMOTE_CHECKPT_DIR"
# ################ SECURITY ALERT ################

echoDebug "About to sync remote $REMOTE_CHECKPT_DIR/$CHECKPOINT content with local $CHECKPT_DIR"

rsyncFrom $SOURCE "$REMOTE_CHECKPT_DIR/$CHECKPOINT/" "$CHECKPT_DIR" "-acz --delete" || error_exit "checkpoint rsync"


TARGET_CONTAINER=$(docker create \
	--volumes-from $UCONT_ID \
	--volumes-from $UCONT_ID_RO:ro \
	"$LOCAL_REGISTRY/$IMAGE")

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
echoDebug "CHANGED_VOLS=$CHANGED_VOLS"

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

	# TODO: update volumes registry

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

# TODO: $CHECKPT_ARCHIVES and checkpoints registry?

if [ ! $DEBUG_MODE ]; then
	cd ..
	rm -rv $WORKDIR
fi

# remove remote dir ???
