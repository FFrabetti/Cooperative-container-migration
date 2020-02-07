#!/bin/bash

VERS=$1
DIM=$2

currdir=$(pwd)

[ -d docker_build ] && rm -rf docker_build
mkdir -p docker_build
tar -xf Cooperative-container-migration/executable/trafficgen.tar -C docker_build
cd docker_build/trafficgen
docker build -t trafficgen:$VERS .


echo "layerfile_b size $DIM:"
get_filler_file.sh $DIM 1 | docker run --name "${VERS}b" -i trafficgen:$VERS /bin/bash -c "tee layerfile_b" | wc -c

docker commit ${VERS}b trafficgen:${VERS}b
docker container rm -f ${VERS}b


echo "layerfile_c size $DIM:"
get_filler_file.sh $DIM 2 | docker run --name "${VERS}c" -i trafficgen:${VERS}b /bin/bash -c "tee layerfile_c" | wc -c

docker commit ${VERS}c trafficgen:${VERS}c
docker container rm -f ${VERS}c


echo "layerfile_d size $DIM:"
get_filler_file.sh $DIM 3 | docker run --name "${VERS}d" -i trafficgen:${VERS}c /bin/bash -c "tee layerfile_d" | wc -c

docker commit --change='CMD ["catalina.sh", "run"]' ${VERS}d trafficgen:${VERS}d
docker container rm -f ${VERS}d


# debug
docker image history trafficgen:${VERS}d

cd $currdir
