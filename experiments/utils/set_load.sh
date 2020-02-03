#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

timeout=$1

# load value between 1-10

while read node load; do
	sshrootbg ${!node} "set_local_load.sh $load $timeout" < /dev/null
done
