#!/bin/bash

source ./config.sh

while read name; do
	ps -C $name -o pid= | xargs -r kill -kill
done < "$backgrounddir/running.list"

rm -rf "$backgrounddir/*"
