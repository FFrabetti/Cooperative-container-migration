#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

timeout=$1

# load value between 1-10

while read node load; do
	sshroot ${!node} "set_load_local.sh $load $timeout" < /dev/null
done
