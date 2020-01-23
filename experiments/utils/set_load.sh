#!/bin/bash

source ./config.sh

timeout=$1

# load value between 1-10

while read node load; do
	sshroot ${!node} "set_load_local.sh $load $timeout" < /dev/null
done
