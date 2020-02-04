#!/bin/bash

declare -A row

for var in "$@"; do
	while read line; do
		echo "$line $var"
	done < $var
done | sort > mergedresults.txt

# headers
echo "timestamp" "$@"

echo "999 v f" >> mergedresults.txt
cur_time=0
while read time value filename; do
	if [ $cur_time -eq $time -o $cur_time -eq 0 ]; then
	   row[$filename]=$value
	else
		echo -n "$cur_time "
		for col in "$@"; do
			if [ ${row[$col]+a} ]; then
				echo -n "${row[$col]} "
			else
				echo -n "0 "
			fi
		done
		echo "" 	# new line
		unset row
		declare -A row
		row[$filename]=$value
	fi
	cur_time=$time
done < mergedresults.txt
