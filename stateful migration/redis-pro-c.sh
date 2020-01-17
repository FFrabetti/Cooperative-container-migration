#!/bin/bash

# [$1 := HOST]
# [$2 := PORT]

HOST="localhost"
if [ $# -ge 1 ]; then
	HOST="$1"
fi

PORT=6379
if [ $# -ge 2 ]; then
	PORT=$2
fi

while read line; do
	if [ "$line" ]; then
		if [[ "$line" = "get"* ]]; then
			(echo "readonly"; echo $line) | redis-cli -h "$HOST" -p $PORT
		else
			# using cluster mode (follow redirections)
			redis-cli -h "$HOST" -p $PORT -c $line
		fi
	else
		echo "exit"
		break
	fi
done
