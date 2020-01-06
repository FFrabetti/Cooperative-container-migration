#!/bin/bash

if [ "$1" == "ALL" ]; then 	# extract all tars
	cat /backup/*.tar | tar -xvf - -i -C /

	# debug
	for arch in /backup/*.tar; do
		echo -n "archive: $arch"
		DIR=$(tar -tf $arch | head -1)
		echo " in $DIR"
	done
else
	while (($#)); do
		tarfile="/backup/$1.tar"
		# if file "$tarfile" | grep -q 'tar archive'; then 	# just for uncompressed tars
		if [ -f "$tarfile" ]; then
			tar -xvf "$tarfile" -C /
		else
			echo "$tarfile is not a tar archive"
		fi
		shift
	done
fi
