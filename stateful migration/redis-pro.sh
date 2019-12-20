#!/bin/bash

# $1 := MASTER_HOST
# $2 := MASTER_PORT
# [$3 := SLAVE_HOST]
# [$4 := SLAVE_PORT]

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
	echo "Usage: $0 MASTER_HOST MASTER_PORT [SLAVE_HOST [SLAVE_PORT]]"
	exit 1
fi

MASTER_HOST="$1"
MASTER_PORT=$2

SLAVE_HOST="localhost"
if [ $# -ge 3 ]; then
	SLAVE_HOST="$3"
fi

SLAVE_PORT=6379
if [ $# -ge 4 ]; then
	SLAVE_PORT=$4
fi

while read line; do
	if [ "$line" ]; then
		if [[ "$line" = "get"* ]]; then
			redis-cli -h "$SLAVE_HOST" -p $SLAVE_PORT $line
		else
			redis-cli -h "$MASTER_HOST" -p $MASTER_PORT $line
		fi
	else
		echo "exit"
		break
	fi
done
