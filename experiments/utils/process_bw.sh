#!/bin/bash

source processing-functions.sh

currdir=$(pwd)

tfile=$(mktemp)

for d in "$@"; do
	if [ -d "$d" ]; then
		cd "$d"
		
		a=$(cat args)
		
		for bw in $(ls bandwidth_*); do
			if [ -f $bw ]; then
				echo "$a $bw $(getBandwidth $bw)"
			fi
		done
		
		cd "$currdir"
	fi
done > $tfile

sort $tfile
