#!/bin/bash

# usage example: ls | grep cm_sl | sort | process_load.sh

currdir=$(pwd)

i=0
while read d; do
	if [ -d "$d" ]; then
		cd "$d"
	
		read mstart mend < migr_time
		mstart=$(echo $mstart | cut -c -10)
		mend=$(echo $mend | cut -c -10)
		
		for ld in $(ls pr.load*); do
			if [ -f $ld ]; then
				# echo "$i $d/$ld"
				awk '$1<'$mstart' { btot+=$2; b+=1 }
					$1>='$mstart' && $1<'$mend' { dtot+=$2; d+=1 }
					$1>='$mend' { atot+=$2; a+=1 }
					END { print "'$i'", "'$ld'", btot, b, (btot/b), dtot, d, (dtot/d), atot, a, (atot/a) }' "$ld"
			fi
		done
		
		cd "$currdir"
	fi
	
	i=$(( (i+1) % 36 ))
done
