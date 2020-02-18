#!/bin/bash

# usage example: ls | grep cm_sl | sort | process_migrtime.sh 	# 2>/dev/null

currdir=$(pwd)

tfile=$(mktemp)

i=0
while read d; do
	if [ -d "$d" ] && [ -f "$d/args" ]; then
		cd "$d"
		
		#a=$(awk '{ for(i=1; i<=NF; i++) printf("%s_", $i) }' args)
		a=$(cat args)
		
		if [ -f migr_time ]; then
			#mt=$(tail -1 migr_time)
			mt=$(awk 'END { print $1 }' migr_time) 	# we don't need "ms"
			index=$i
			if [ $i -lt 10 ]; then 	# for sort
				index="0$i"
			fi
			
			echo "$index $a $mt"
		fi
		
		cd "$currdir"
	fi
	
	i=$(( (i+1) % 36 ))
done | tee $tfile >&2

#awk 'BEGIN { print "exp","tot","avg" } { arr[$1]+=$NF } END { for(key in arr) print key, arr[key], (arr[key]/2) }' $tfile

sort $tfile | awk 'BEGIN { arg="" }
	{ if($1 == arg) line = line " " $NF; else { if(line) print line; arg=$1; line = $1 " " $NF } }
	END { print line }'
