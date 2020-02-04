#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

for name in mpstat tcpdump stress ifstat; do
	ps -C $name -o pid= | xargs -r kill -kill
done

rm -rf "$backgrounddir/*"
