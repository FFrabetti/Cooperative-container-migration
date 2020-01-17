#!/bin/bash

# $1 := <VERSION>

if [ $# -ne 1 ]; then
	echo "Usage: $0 VERSION"
	exit 1
fi

# https://github.com/docker/compose/releases

sudo curl -L https://github.com/docker/compose/releases/download/$1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version

# https://docs.docker.com/compose/install/
