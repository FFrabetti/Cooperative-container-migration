#!/bin/bash

# $1 := REDIS_HOST
# $2 := CHANNEL

REDIS_HOST="$1"
CHANNEL="$2"

# line buffered output
# stdbuf -oL redis-cli ...

IFS=","
stdbuf -oL redis-cli -h "$REDIS_HOST" --csv SUBSCRIBE "$CHANNEL" | while read type channel value; do

	# https://redis.io/topics/pubsub
	# $type		:= subscribe	|	unsubscribe	|	message
	# $value	:= NR_CHANNELS	|	NR_CHANNELS	|	MSG_PAYLOAD

	if [ $type = "message" ]; then 	# or use: case $type in ... esac
		echo "Received message: $value"
		# do some processing...
	else
		echo "$type $channel $value"
	fi
done
