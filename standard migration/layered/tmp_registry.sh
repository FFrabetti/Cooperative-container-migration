#!/bin/bash

REG="tmp_registry"
STOP="stop"

# https://github.com/docker/distribution/blob/master/docs/configuration.md#delete
# enable the deletion of image blobs and manifests by digest (default false)

if [ $# -ne 1 ]; then	# start
	docker run -d \
		-p 5000:5000 \
		--restart=on-failure \
		-e REGISTRY_STORAGE_DELETE_ENABLED=true \
		-e REGISTRY_LOG_LEVEL=debug \
		--name $REG \
		registry:2	
elif [ $1 = $STOP ]; then	# stop
	# -v 	Remove the volumes associated with the container
	docker container stop $REG && docker container rm -v $REG
else
	echo "Invalid argument. Use:"
	echo -e "\t $0 \t to start the registry"
	echo -e "\t $0 $STOP \t to stop the registry"
fi
