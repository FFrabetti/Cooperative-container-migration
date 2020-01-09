#!/bin/bash

which redis-cli > /dev/null || { echo "Error: redis-cli not found"; exit 1; }

# ${parameter:-word}
# If parameter is unset or null, the expansion of word is substituted. Otherwise, the value of parameter is substituted.

function selectNeighborWithVol { # policy: highest score
	[ $# -eq 2 ] && { local RHOST="-h $1"; shift; }
	local KEY="$1"
	
	redis-cli --raw ${RHOST:-} ZREVRANGE "$KEY" 0 0 	# <- START STOP (inclusive)
}

function updateVolRegistry {
	[ $# -eq 4 ] && { local RHOST="-h $1"; shift; }
	local KEY="$1"
	local VALUE="$2"
	local SCORE=$3
	
	redis-cli --raw ${RHOST:-} ZADD "$KEY" $SCORE "$VALUE"
}

function selectNeighborWithCheckpt { # policy: most recent checkpoint of the container, or the "best" from the same application
	[ $# -eq 3 ] && { local RHOST="-h $1"; shift; }
	local IMAGE_TAG="$1"
	local USER_ID="$2"
	
	local RES=$(redis-cli --raw ${RHOST:-} ZREVRANGE "$IMAGE_TAG:$USER_ID" 0 0)
	if [ $RES ]; then
		echo $RES
	else
		redis-cli --raw ${RHOST:-} ZREVRANGE "$IMAGE_TAG" 0 0
	fi
}

# [HOST] IMAGE_TAG (USER_ID | "") VALUE SCORE
# IMAGE_TAG VALUE SCORE
function updateCheckptRegistry {
	[ $# -eq 5 ] && { local RHOST="-h $1"; shift; }
	local IMAGE_TAG="$1"
	if [ $# -eq 4 ] && [ ! "$2" = "" ]; then
		local KEY=":$2" 	# :$USER_ID
		shift
	fi
	local VALUE="$2"
	local SCORE=$3
	
	redis-cli --raw ${RHOST:-} ZADD "$IMAGE_TAG${KEY:-}" $SCORE "$VALUE"
}
