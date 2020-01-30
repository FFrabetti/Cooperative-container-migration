#!/bin/bash

function getBandwidth { # FILENAME -> TIMESTAMP BW
	local bw=$(tail -3 $1 | head -1 | rev | awk '{ print $2 " " $3 }' | rev)
	local ts=$(head -1 $1)
	
	echo "$ts $bw"
}

function getTrafficPktLen {
	#awk '{ print $1 " " $NF }'
	#awk 'BEGIN { FS = "[. ]" } { print $1 " " $3 }'
	awk 'BEGIN { FS = "[. ]" } { arr[$1]+=$NF } END { for(key in arr) print key " " arr[key] }' | sort
	
	# ... { for(key in arr) { system("date -d @" key " +%H:%M:%S"); print key " " arr[key] } } ... 
}

function timestampToTime {
	date -d @$1 +%H:%M:%S
}

# the first line has the date:
# Linux 4.4.0-142-generic (ubuntu4) 	01/24/2020 	_x86_64_	(2 CPU)
# AM or PM is in $2
function getTimeIdle { # e.g. 10:44:47 97.47
	read one two three date other
	local tokens=$(echo $date | awk 'BEGIN { FS="/" } { print $1,$2,$3 }')
	read
	read
	
	myGetTimeIdle $tokens
}

function myGetTimeIdle {
#	awk '{ print $1 " " $NF }'
	awk 'BEGIN { FS="[ :]" } { print mktime("'$3' '$1' '$2' " $1 " " $2 " " $3), $NF }'
}

function getInteractiveCli {
	#awk '{ print $2 $4 $8 }'
	awk '{ if($4 == "INFO") { if($8 == "request:") req = $2; else print $2, req, $1, $8 } }' | awk 'BEGIN { FS = "[ :,-]" } { t2 = ($1 * 3600 + $2 * 60 + $3) * 1000 + $4; t1 = ($5 * 3600 + $6 * 60 + $7) * 1000 + $8; diff = t2 - t1; print mktime($9 " " $10 " " $11 " " $1 " " $2 " " $3), diff }'
	# e.g. 21:01:02,270 21:01:02,058 received:
}

function getAverageOverS {
	awk '{ arr[$1]+=$2; n[$1]+=1 } END { for(key in arr) print key, (arr[key] / n[key]) }' | sort
}