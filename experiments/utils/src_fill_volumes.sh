#!/bin/bash

volumesize=$1
shift

i=0
while (( $# )); do
	vname="$1"
	i=$((i+1))
	if ! docker volume inspect $vname &>/dev/null; then
		docker volume create --label rw-guid=${vname}_guid $vname 	# $(cat /proc/sys/kernel/random/uuid)
		get_filler_file.sh $volumesize $i | docker run --rm -i -v $vname:"/testrw" busybox /bin/sh -c "tee /testrw/testfile" | wc -c 	# > /dev/null
	fi
	shift
done
