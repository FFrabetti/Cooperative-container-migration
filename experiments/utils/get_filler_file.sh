#!/bin/bash

SIZE=$1 	# in KB (or xxxMB)
INDEX=$2 	# 1..95 -> +31 -> 32..126 DEC (see: man ascii)

INDEX=$(((INDEX - 1) % 95 + 1))
DEC=$((INDEX + 31))

# awk 'BEGIN { printf("%c", '$DEC') }'

filename="filler$INDEX"

# create filler files if not present
if [ ! -f $filename ]; then
#	awk 'BEGIN { for(i=0; i<1024; i++) printf("%c", '$DEC') }' > $filename
	awk 'BEGIN { srand('$DEC'); for(i=0; i<1024; i++) printf("%c", int(rand()*1000) % 95 + 32) }' > $filename
fi

if [[ $SIZE =~ ([0-9]+)M ]]; then
	SIZE=${BASH_REMATCH[1]}
	
	mfile="${filename}M"
	if [ ! -f $mfile ]; then
		for i in {1..1024}; do
			cat $filename >> $mfile
		done
	fi
	
	filename=$mfile
fi

echo "filler file $filename $SIZE times" >&2
count=0

# now SIZE and filename are independent of KB or MB
for j in $(seq 1 $SIZE); do
	cat $filename
	count=$((count+1))
done

echo "count = $count (it should be $SIZE)" >&2
