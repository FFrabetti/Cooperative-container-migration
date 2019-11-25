#!/bin/bash

if [ $# -eq 3 ]; then
	# $1 := <REGISTRY_ADDR>
	# $2 := <REPO>
	# $3 := <DIGEST>
	RES=$(curl -sS $1/v2/$2/blobs/$3 \
		-I -X HEAD \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip" \
		-w "%{http_code}" | tail -1)

	# echo $RES
	if [ $RES = "200" ]; then
		exit 0
	else
		exit 1
	fi

else
	echo "Usage: $0 <REGISTRY_ADDR> <REPO> <DIGEST>"
	exit 1
fi
