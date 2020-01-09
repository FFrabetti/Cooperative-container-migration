#!/bin/bash

source $(dirname "$0")/redis-functions.sh

SOURCE="$1"
MASTER_IP="$2"
USER_ID="$3"

IMAGE_TAG=$(ssh $SOURCE "docker container inspect toytsm -f '{{.Config.Image}}'")
IMAGE=$(echo $IMAGE_TAG | cut -d/ -f2)

[ $(docker version -f '{{.Server.Experimental}}') = "true" ] || { echo "Error: you have to enable Docker experimental features"; exit 1; }


# ################################ Redis C/S ################################
docker run -d -p 6379:6379 --name myredis redis
# or: docker container start myredis

sudo apt-get install redis-tools
redis-cli ping || { echo "Error: cannot ping the server"; exit 1; }


# ################################ Volumes ################################
RO_GUID=$(python3 -c "import base64; print(base64.urlsafe_b64encode(\"$IMAGE/testro\".encode()).decode())")
RW_GUID=$(ssh $SOURCE "docker volume ls -f name=testrw --format '{{.Label \"rw-guid\"}}'")

VOL_ARCHIVES="/volume_archives"
sudo mkdir -p $VOL_ARCHIVES
sudo chown $USER $VOL_ARCHIVES

DIR=$(mktemp -d)
docker run --rm -v $DIR:/outtar -v /testro \
	ubuntu /bin/bash -c 'echo "Read-only content" > /testro/testfile; tar cPf /outtar/testro.tar /testro'
mv -f $DIR/testro.tar "$VOL_ARCHIVES/ro.${RO_GUID}.tar"

docker run --rm -v $DIR:/outtar -v /testrw \
	ubuntu /bin/bash -c 'i=0; while [ $i -lt 5 ]; do echo $i | tee -a /testrw/counter; i=$((i+1)); sleep 1; done; tar cPf /outtar/testrw.tar /testrw'
mv -f $DIR/testrw.tar "$VOL_ARCHIVES/rw.${RW_GUID}.tar"

# debug
ls -l $VOL_ARCHIVES
tar tPvf "$VOL_ARCHIVES/ro.${RO_GUID}.tar"
tar tPvf "$VOL_ARCHIVES/rw.${RW_GUID}.tar"

# ################################ Checkpoint ################################
CHECKPT_ARCHIVES="/checkpt_archives"
sudo mkdir -p $CHECKPT_ARCHIVES
sudo chown $USER $CHECKPT_ARCHIVES

docker run -d --rm --name toytsm -v /testrw -v /testro $IMAGE_TAG
	
echo "Waiting a few seconds..."
sleep 10

cd $DIR
docker checkpoint create toytsm cp1 --checkpoint-dir="$(pwd)"
sudo tar cf "$CHECKPT_ARCHIVES/$IMAGE.tar" cp1
docker container rm -f toytsm

# debug
ls -l $CHECKPT_ARCHIVES


# ################################ Insert data into Redis ################################
echo -n "Add to rw:$RW_GUID value $MASTER_IP (100): "
updateVolRegistry "rw:$RW_GUID" $MASTER_IP 100
echo -n "Add to ro:$RO_GUID value $MASTER_IP (100): "
updateVolRegistry "ro:$RO_GUID" $MASTER_IP 100
echo -n "Add to ro:$RO_GUID value $SOURCE (20): "
updateVolRegistry "ro:$RO_GUID" $SOURCE 20 		# the source has to have it

scp "$VOL_ARCHIVES/ro.${RO_GUID}.tar" $SOURCE:"$VOL_ARCHIVES/"

# same container and same application
TIMESTAMP=$(date +%s)
echo -n "Add to $IMAGE $USER_ID value $MASTER_IP ($TIMESTAMP): "
updateCheckptRegistry $IMAGE $USER_ID $MASTER_IP $TIMESTAMP
echo -n "Add to $IMAGE value $MASTER_IP (100): "
updateCheckptRegistry $IMAGE $MASTER_IP 100

# debug
echo -n "Select from rw:$RW_GUID: "
selectNeighborWithVol "rw:$RW_GUID"
echo -n "Select from ro:$RO_GUID: "
selectNeighborWithVol "ro:$RO_GUID"

echo -n "Select from $IMAGE $USER_ID: "
selectNeighborWithCheckpt $IMAGE $USER_ID
echo -n "Select from $IMAGE: "
selectNeighborWithCheckpt $IMAGE "other user"
