#!/bin/bash

# [$1 = BACKUP_DIR]

BACKUP_DIR="/backup"
if [ $# -eq 1 ]; then
	BACKUP_DIR="$1"
fi

count=0
while read volname volpath rest; do
	if [[ $volname ]] && [[ $volpath ]]; then 	# no empty lines
		echo "$volname in $volpath" 	# debug
		tar -cPvf "$BACKUP_DIR"/$volname.tar $volpath && count=$((count+1))
		# -P 	don't strip leading / from file names
	fi
done

# debug message (sent to container log or stdout with run -a)
echo "$count volumes backed up!"
