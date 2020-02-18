#!/bin/bash

# usage example: ls | grep cm_sl | sort | process_traffic.sh

currdir=$(pwd)

i=0
while read d; do
	if [ -d "$d" ]; then
		cd "$d"
	
		for tr in $(ls pr.traffic*); do
			if [ -f $tr ]; then
				# echo "$i $d/$tr"
				awk 'BEGIN { print "time", "KB", "thr" }
					NR==1 { start=$1 }
					{ tot+=$2 }
					END { tottime=$1-start; print "'$i'", "'$tr'", tottime, tot, (tot/tottime) }' "$tr"
			fi
		done
		
		cd "$currdir"
	fi
	
	i=$(( (i+1) % 36 ))
done
