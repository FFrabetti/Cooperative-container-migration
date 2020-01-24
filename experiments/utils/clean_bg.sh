#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

while read name; do
	ps -C $name -o pid= | xargs -r kill -kill
done < "$backgrounddir/running.list"

rm -rf "$backgrounddir/*"
