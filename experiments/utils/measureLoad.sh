#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

usage () {
  echo "Usage:"
  echo "   ./$(basename $0) loadTime_in_seconds fileName"
  exit 0
}

if [[ ( $# == "--help") ||  $# == "-h" ]]
        then
                usage
                exit 0
fi

if [ "$#" -lt 2 ]; then
  echo "Insufficient parameters!"
  usage
fi

loadtime=$1
idlefile=$2

mpstatfile="mpstat.txt"

mpstat $loadtime > $mpstatfile &

whilef=$(whileBackground "measureLoad")
while [ -e $whilef ]; do
	#time stored in ns
	#date +%s%N
	awk 'END {print $NF}' $mpstatfile > $idlefile
	sleep $loadtime
done &
