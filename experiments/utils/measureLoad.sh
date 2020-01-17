#!/bin/bash
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
mpstat $loadtime > util.txt &
mpstatpid=$!
while [ 1 ]
do
#time stored in ns
#  curTime='date +%s%N'
  echo $(date +%s%N),$(awk 'END {print $NF}' util.txt) >> $idlefile
  sleep $loadtime
done
kill -9 $mpstatpid
rm -f util.txt
