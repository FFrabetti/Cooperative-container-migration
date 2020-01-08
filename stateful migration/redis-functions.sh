#!/bin/bash

CLIENT="redis-client.sh"
PATH="$PATH:."
! which $CLIENT > /dev/null && [ ! -x $CLIENT ] && echo "Error: $CLIENT not found" && exit 1


function selectNeighborWithVol { # policy: highest score
	REDIS_HOST="$1"
	KEY="$2"
	
	$CLIENT "$REDIS_HOST" ZREVRANGE "$KEY" 0 0 	# <- START STOP (inclusive)
}

function updateVolRegistry {
	REDIS_HOST="$1"
	KEY="$2"
	VALUE="$3"
	SCORE=$4
	
	$CLIENT "$REDIS_HOST" ZADD "$KEY" $SCORE "$VALUE"
}

function selectNeighborWithCheckpt {
	REDIS_HOST="$1"
	IMAGE_TAG="$2"
	USER_ID="$3"
	
	RES=$($CLIENT "$REDIS_HOST" ZREVRANGE "$IMAGE_TAG" 0 0)
	if [ $RES ]; then
		echo $RES
	else
		$CLIENT "$REDIS_HOST" ZREVRANGE "$IMAGE_TAG:$USER_ID" 0 0
	fi
}

function updateCheckptRegistry { 	# HOST IMAGE_TAG [USER_ID] VALUE SCORE
	REDIS_HOST="$1"
	KEY="$2" 			# IMAGE_TAG
	if [ $# -eq 5 ]; then
		KEY="$KEY:$3" 	# USER_ID
		shift
	fi
	VALUE="$3"
	SCORE=$4
	
	$CLIENT "$REDIS_HOST" ZADD "$KEY" $SCORE "$VALUE"
}
