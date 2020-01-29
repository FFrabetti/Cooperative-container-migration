#!/bin/bash

function getBandwidth { # FILENAME -> TIMESTAMP,BW
	local bw=$(tail -3 $1 | head -1 | rev | awk '{ print $2 " " $3 }' | rev)
	local ts=$(tail -1 $1)
	
	echo "$ts,$bw"
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
	awk '{ print $1 " " $NF }'
}

function getInteractiveCli {
	#awk '{ print $2 $4 $8 }'
	awk '{ if($4 == "INFO") { if($8 == "request:") req = $2; else print $2 " " req " " $8 } }'
	
	# e.g. 21:01:02,270 21:01:02,058 received:
}
