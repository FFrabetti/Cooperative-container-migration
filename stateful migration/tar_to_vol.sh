#!/bin/bash

if [ $# -gt 0 ]; then
	while (($#)); do
		tar -xvf /backup/"$1".tar -C /
		shift
	done
else 	# if no arguments, extract all tars
	cat /backup/*.tar | tar -xvf - -i -C /

	# debug
	for arch in /backup/*.tar; do
		echo -n "archive: $arch"
		DIR=$(tar -tf $arch | head -1)
		echo " in $DIR"
	done
fi
