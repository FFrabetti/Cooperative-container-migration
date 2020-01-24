#!/bin/bash

VERS=$1
DIM=$2
# $3 := MB

tar -xf Cooperative-container-migration/executable/trafficgen.tar
cd trafficgen
docker build -t trafficgen:$VERS .

# create filler files if not present
if [ ! -f fillerB ]; then
	for j in {1..1024}; do 	# 1 KB
		echo -n -e '\x66' >> fillerB
	done
fi

if [ ! -f fillerC ]; then
	for j in {1..1024}; do 	# 1 KB
		echo -n -e '\x67' >> fillerC
	done
fi

if [ ! -f fillerD ]; then
	for j in {1..1024}; do 	# 1 KB
		echo -n -e '\x68' >> fillerD
	done
fi

if [ ! -f fillerB_1M ]; then
	for f in fillerB fillerC fillerD; do
		for i in {1..1024}; do
			cat $f >> "${f}_1M"
		done
	done
fi

basefile=fillerB
if [ $# -eq 3 ]; then
	basefile=fillerB_1M
fi

docker run --name "${VERS}b" -it -v "$(pwd)/$basefile":/base trafficgen:$VERS /bin/bash -c "
for i in \$(seq 1 $DIM); do
	cat /base >> fB
done"

docker commit ${VERS}b trafficgen:${VERS}b
docker container rm -f ${VERS}b


basefile=fillerC
if [ $# -eq 3 ]; then
	basefile=fillerC_1M
fi

docker run --name "${VERS}c" -it -v "$(pwd)/$basefile":/base trafficgen:${VERS}b /bin/bash -c "
for i in \$(seq 1 $DIM); do
	cat /base >> fC
done"

docker commit ${VERS}c trafficgen:${VERS}c
docker container rm -f ${VERS}c


basefile=fillerD
if [ $# -eq 3 ]; then
	basefile=fillerD_1M
fi

docker run --name "${VERS}d" -it -v "$(pwd)/$basefile":/base trafficgen:${VERS}c /bin/bash -c "
for i in \$(seq 1 $DIM); do
	cat /base >> fD
done"

docker commit ${VERS}d trafficgen:${VERS}d
docker container rm -f ${VERS}d
