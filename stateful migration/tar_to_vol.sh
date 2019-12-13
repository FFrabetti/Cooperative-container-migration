#!/bin/bash

cat /backup/*.tar | tar -xvf - -i -C /

# debug
for arch in /backup/*.tar; do
	echo -n "archive: $arch"
	DIR=$(tar -tf $arch | head -1)
	echo " in $DIR"
done
