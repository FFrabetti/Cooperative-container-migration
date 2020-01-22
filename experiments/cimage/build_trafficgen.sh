#!/bin/bash

DIM=$1 	# LAYER_DIM (kB)
VERS=t$2

tar -xf Cooperative-container-migration/executable/trafficgen.tar
cd trafficgen
docker build -t trafficgen:$VERS .


docker run --name "${VERS}b" -it trafficgen:$VERS /bin/bash -c "
for i in \$(seq 1 $DIM); do
	for j in {1..1000}; do
		echo -n -e '\x66' >> fillerB
	done
done"

docker commit ${VERS}b trafficgen:${VERS}b
docker container rm -f ${VERS}b

docker run --name "${VERS}c" -it trafficgen:${VERS}b /bin/bash -c "
for i in \$(seq 1 $DIM); do
	for j in {1..1000}; do
		echo -n -e '\x67' >> fillerC
	done
done"

docker commit ${VERS}c trafficgen:${VERS}c
docker container rm -f ${VERS}c

docker run --name "${VERS}d" -it trafficgen:${VERS}c /bin/bash -c "
for i in \$(seq 1 $DIM); do
	for j in {1..1000}; do
		echo -n -e '\x68' >> fillerD
	done
done"

docker commit ${VERS}d trafficgen:${VERS}d
docker container rm -f ${VERS}d
