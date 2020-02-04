#!/bin/bash

function getBandwidth { # FILENAME -> TIMESTAMP BW
	local bw=$(tail -3 $1 | head -1 | rev | awk '{ print $2 " " $3 }' | rev)
	local ts=$(head -1 $1)
	
	echo "$ts $bw"
}

function getTrafficPktLen {
	#awk '{ print $1 " " $NF }'
	#awk 'BEGIN { FS = "[. ]" } { print $1 " " $3 }'
	# e.g. length 259: 
	awk 'BEGIN { FS="[:. ]" } { for(i=1; i<NF; i++) { if($i == "length") arr[$1]+=$(i+1) } } END { for(key in arr) print key " " arr[key] }' | sort
	
	# ... { for(key in arr) { system("date -d @" key " +%H:%M:%S"); print key " " arr[key] } } ... 
}

function timestampToTime {
	TZ=UTC+5 date -d @$1 +%H:%M:%S
}

function dateToTimestamp {
	# MM/DD/YYYY HH:MM:SS [PM]	
	TZ=UTC+5 date --date="$1" +%s
}

# the first line has the date:
# Linux 4.4.0-142-generic (ubuntu4) 	01/24/2020 	_x86_64_	(2 CPU)
function getTimeIdle {
	read one two three date other
	read
	read
	
	awk '{ print $NF, "'$date'", $1, $2 }' | while read value datetime; do
		echo $(dateToTimestamp "$datetime") $value
	done
}

#function myGetTimeIdle {
#	awk '{ print $1 " " $NF }'
#	awk 'BEGIN { FS="[ :]" } { if($4 == "PM") $1+=12; print mktime("'$3' '$1' '$2' " $1 " " $2 " " $3), $NF } }'
#}

function processIfstat { # $1 filein $2 fileout
	read date
	read header1
	read header2
	while read hour int outt; do
		echo $(dateToTimestamp "$date $hour") $int >> $1
		echo $(dateToTimestamp "$date $hour") $outt >> $2
	done
}

function getInteractiveCli {
	#awk '{ print $2 $4 $8 }'
	awk '{ if($4 == "INFO") { if($8 == "request:") req = $2; else print $2, req, $1, $8 } }' | awk 'BEGIN { FS = "[ :,-]" } { t2 = ($1 * 3600 + $2 * 60 + $3) * 1000 + $4; t1 = ($5 * 3600 + $6 * 60 + $7) * 1000 + $8; diff = t2 - t1; print diff, $9 "-" $10 "-" $11 " " $1 ":" $2 ":" $3 }' | while read value datetime; do
		echo $(dateToTimestamp "$datetime") $value
	done
	
	#awk 'BEGIN { FS = "[ :,-]" } { t2 = ($1 * 3600 + $2 * 60 + $3) * 1000 + $4; t1 = ($5 * 3600 + $6 * 60 + $7) * 1000 + $8; diff = t2 - t1; print mktime($9 " " $10 " " $11 " " $1 " " $2 " " $3), diff }'
	# e.g. 21:01:02,270 21:01:02,058 received:
}

function getAverageOverS {
	awk '{ arr[$1]+=$2; n[$1]+=1 } END { for(key in arr) print key, (arr[key] / n[key]) }' | sort
}
