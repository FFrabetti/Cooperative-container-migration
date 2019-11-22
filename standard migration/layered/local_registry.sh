#!/bin/bash

# docker container ls
# docker container ls -a | grep registry
# docker container start [sec_]registry

# ################ START/STOP LOCAL REGISTRY ################
# $1	if present, run sec_registry (with TLS) using $1 as the directory where to look for domain.crt and domain.key
if [ $# -ne 1 ]; then
	docker run -d \
		-p 5000:5000 \
		-v /home/ubu2admin/registry:/var/lib/registry \
		--restart=unless-stopped \
		--name registry \
		registry:2
else
	CERTS=$(cd "$1"; pwd) 	# absolute path (cd performed in a sub-shell)
	CONFIG_FILE="config.yml"
	echo "Running registry with TLS (certificate in $CERTS) ..."
	
	if [ ! -f "$CONFIG_FILE" ]; then
		docker run -d \
			-p 443:443 \
			-v "$CERTS":/certs \
			-e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
			-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
			-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
			-v /home/ubu2admin/registry:/var/lib/registry \
			--restart=unless-stopped \
			--name sec_registry \
			registry:2
	else
		# instead of using -e arguments, you can specify an alternate YAML configuration file by mounting it as a volume in the container
		echo "... using $CONFIG_FILE configuration file ..."
		docker run -d \
			-p 443:443 \
			-v "$CERTS":/certs \
			-v /home/ubu2admin/registry:/var/lib/registry \
			-v `pwd`/$CONFIG_FILE:/etc/docker/registry/config.yml \
			--restart=unless-stopped \
			--name sec_registry \
			registry:2
	fi
fi

# If you want to change the port the registry listens on within the container
#	-e REGISTRY_HTTP_ADDR=0.0.0.0:5001 \
#	-p <HOST_PORT>:5001 \

# By default, registry data is persisted as a docker volume on the host filesystem
# you can choose to use a bind-mount instead
# -v /home/ubu2admin/registry:/var/lib/registry \

# https://hub.docker.com/_/registry?tab=tags
# TAG				DIGEST				OS/ARCH
# :latest			b1165286043f		linux/amd64
# :2				b1165286043f		linux/amd64

# https://docs.docker.com/engine/reference/run/#restart-policies---restart
# --restart
# no
#		Do not automatically restart the container when it exits (default).
# on-failure[:max-retries]
#		Restart only if the container exits with a non-zero exit status.
# always
#		Always restart (indefinitely) and on daemon startup, regardless of the current state of the container.
# unless-stopped
# 		Like "always", except if the container was stopped before the daemon was stopped.

# read about non-distributable images
# https://docs.docker.com/registry/deploying/#considerations-for-air-gapped-registries


# #### stop and clean-up ####
# docker container stop registry
# docker container stop registry && docker container rm -v registry


# #### using docker-compose ####
# cd in the directory containing the .yaml file
# docker-compose up -d				# detached (run in background)

# docker-compose ps
# docker-compose stop
# docker-compose down 				# remove all containers
# docker-compose down --volumes 	# also remove volumes
# ################ ################ ################


# SOURCE_TAG="node-web-app:v3.1"
# REGISTRY_TAG="localhost:5000/node-web-app:v3.1"


# ################ SOURCE: PUSH ################
# docker tag $SOURCE_TAG $REGISTRY_TAG
# docker push $REGISTRY_TAG
# ################ ################ ################


# ################ DESTINATION: PULL ################
# remove tags and locally cached images
# docker image remove $SOURCE_TAG
# docker image remove $REGISTRY_TAG

# docker pull $REGISTRY_TAG
# ################ ################ ################
