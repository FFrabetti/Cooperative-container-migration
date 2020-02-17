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

# get averaged values: awk -f bw.awk
# or all in one line:
# awk '{ if($1 == arg && $2 == ch) line = line " " $4; else { if(line) print line; arg=$1; ch=$2; line = arg " " ch " " $4 } } END { print line }' bw.results
