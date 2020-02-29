#!/bin/bash

VERS=$1
DIM=$2
shift
shift

docker pull ff185/opencv-lane-finding:1.0
docker tag ff185/opencv-lane-finding:1.0 lanefinding:$VERS


echo "layerfile_b size $DIM:"
get_filler_file.sh $DIM 1 | docker run --name "${VERS}b" -i lanefinding:$VERS /bin/bash -c "tee layerfile_b" | wc -c

docker commit ${VERS}b lanefinding:${VERS}b
docker container rm -f ${VERS}b


echo "layerfile_c size $DIM:"
get_filler_file.sh $DIM 2 | docker run --name "${VERS}c" -i lanefinding:${VERS}b /bin/bash -c "tee layerfile_c" | wc -c

docker commit ${VERS}c lanefinding:${VERS}c
docker container rm -f ${VERS}c


echo "layerfile_d size $DIM:"
get_filler_file.sh $DIM 3 | docker run --name "${VERS}d" -i lanefinding:${VERS}c /bin/bash -c "tee layerfile_d" | wc -c

# --change='CMD ["...", "..."]'
str="--change='CMD ["
param=$(echo $@ |  awk '{ for(i=1; i<=NF; i++) { printf("\"%s\"", $i); if(i!=NF) printf(",") } }')
change=$(echo $str $param "]'")

docker commit $change ${VERS}d lanefinding:${VERS}d
docker container rm -f ${VERS}d


# debug
docker image history lanefinding:${VERS}d
