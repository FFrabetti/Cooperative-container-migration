#!/bin/bash

VERS=$1
DIM=$2

[ -d docker_build ] && rm -rf docker_build
tar -xf Cooperative-container-migration/executable/trafficgen.tar -C docker_build
cd docker_build/trafficgen
docker build -t trafficgen:$VERS .


get_filler_file.sh $DIM 1 | docker run --name "${VERS}b" -i trafficgen:$VERS /bin/bash -c "> layerfile_b"

docker commit ${VERS}b trafficgen:${VERS}b
docker container rm -f ${VERS}b


get_filler_file.sh $DIM 2 | docker run --name "${VERS}c" -i trafficgen:${VERS}b /bin/bash -c "> layerfile_c"

docker commit ${VERS}c trafficgen:${VERS}c
docker container rm -f ${VERS}c


get_filler_file.sh $DIM 3 | docker run --name "${VERS}d" -i trafficgen:${VERS}c /bin/bash -c "> layerfile_d"

docker commit --change='CMD ["catalina.sh", "run"]' ${VERS}d trafficgen:${VERS}d
docker container rm -f ${VERS}d
