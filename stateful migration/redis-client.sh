#!/bin/bash

# $1 := REDIS_HOST
# $... := CMD...

if [ $# -lt 2 ]; then
	echo "Usage: $0 REDIS_HOST CMD..."
	exit 1
fi

REDIS_HOST="$1"
shift

# --csv for comma separated values
redis-cli -h "$REDIS_HOST" --raw $@


# to uppercase
#case ${1^^} in
#	"ZADD")
#		;;
#	*)
#		redis-cli -h "$REDIS_HOST" --raw $@
#		;;
#esac
