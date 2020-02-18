#!/bin/bash

# usage example: ls | grep cm_sl | sort | process_latency.sh before_trafficgencl.log

source processing-functions.sh

if [ $# -ne 1 ]; then
	echo "Usage: $0 filename"
	exit 1
fi

i=0
while read d; do
	if [ -d "$d" ] && [ -f "$d/$1" ]; then
		echo "$d/$1" >&2
		getInteractiveCli < "$d/$1"		
	fi | tee -a "$1.$i.txt"
	
	i=$(( (i+1) % 36 ))
done
