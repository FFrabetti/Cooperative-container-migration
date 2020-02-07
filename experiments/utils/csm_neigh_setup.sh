#!/bin/bash

master=$1
vguid=$2
fillersize=$3 	# volumesize - changevol
filleri=$4
vrank=$5


source redis-functions.sh

VOL_ARCHIVES="/volume_archives"
[ -d $VOL_ARCHIVES ] && rm -rf $VOL_ARCHIVES
mkdir -p $VOL_ARCHIVES

DIR=$(mktemp -d)
# docker run --rm -v $DIR:/outtar -v /testro \
	# ubuntu /bin/bash -c 'echo "Read-only content" > /testro/testfile; tar cPf /outtar/testro.tar /testro'
# mv -f $DIR/testro.tar "$VOL_ARCHIVES/ro.${RO_GUID}.tar"

get_filler_file.sh $fillersize $filleri | docker run --rm -i \
	-v $DIR:/outtar -v /testrw \
	ubuntu /bin/bash -c 'tee /testrw/testfile >/dev/null; tar cPf /outtar/testrw.tar /testrw'
mv -f $DIR/testrw.tar "$VOL_ARCHIVES/rw.${vguid}.tar"

echo -n "Add to rw:$vguid value $master ($vrank): "
updateVolRegistry "rw:$vguid" $master $vrank
