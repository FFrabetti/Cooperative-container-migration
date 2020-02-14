#!/bin/bash

DEST="$HOME/exp_results"

if [ $# -eq 1 ]; then
	DEST="$HOME/$1"
fi
mkdir -p $DEST
echo "Copying results to $DEST ..."


function cpfromfolder {
	local d="$DEST/$1"
	if [[ ! "$(pwd)" =~ $DEST ]]; then
		mkdir "$d" 2>/dev/null || echo "$d already exists"

		echo "$d"
		cp args migr_time results* "$d/"
	fi
}

function recursivescan {
	local parent=$(pwd)
	for f in *; do
		if [ -d "$f" ]; then
			cd "$f"
			if [ -f results.csv ]; then
				cpfromfolder "$f"
			else
				recursivescan
			fi
			cd "$parent"
		fi
	done
}

recursivescan
