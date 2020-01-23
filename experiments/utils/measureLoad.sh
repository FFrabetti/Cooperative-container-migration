#!/bin/bash

source ./config.sh

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

mpstatfile="mpstat.$loadtime.txt"

beforeBackground "measureLoad.pid"
mpstat $loadtime > $mpstatfile &
afterBackground "measureLoad.pid" $!

beforeBackground "measureLoad_time.pid"
while [ 1 ]; do
	#time stored in ns
	date +%s%N
	awk 'END {print $NF}' $mpstatfile
	sleep $loadtime
done > $idlefile &
afterBackground "measureLoad_time.pid" $!
