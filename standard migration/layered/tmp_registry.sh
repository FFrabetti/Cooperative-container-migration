#!/bin/bash

REG="tmp_registry"
STOP="stop"

if [ $# -ne 1 ]; then	# start
	docker run -d \
		-p 5000:5000 \
		--restart=on-failure \
		--name $REG \
		registry:2
elif [ $1 = $STOP ]; then
	# -v 	Remove the volumes associated with the container
	docker container stop $REG && docker container rm -v $REG
else
	echo "Invalid argument. Use:"
	echo -e "\t $0 \t to start the registry"
	echo -e "\t $0 $STOP \t to stop the registry"
fi