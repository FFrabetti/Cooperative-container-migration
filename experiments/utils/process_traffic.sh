#!/bin/bash

# usage example: ls | grep cm_sl | sort | process_traffic.sh

currdir=$(pwd)

i=0
while read d; do
	if [ -d "$d" ]; then
		cd "$d"
		
		read mstart mend < migr_time
		mstart=$(echo $mstart | cut -c -10)
		mend=$(echo $mend | cut -c -10)
		
		for tr in $(ls pr.traffic*); do
			if [ -f $tr ]; then
				# echo "$i $d/$tr"
				awk 'NR==1 { start=$1 }
					{ tot+=$2 }
					$1>='$mstart' && $1<'$mend' { mtot+=$2 }
					END {
						tottime=$1-start; mt='$mend'-'$mstart';
						print "'$i'", "'$tr'", tottime, tot, (tot/tottime), mt, mtot, (mtot/mt)
					}' "$tr"
			fi
		done
		
		cd "$currdir"
	fi
	
	i=$(( (i+1) % 36 ))
done
