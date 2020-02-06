#!/bin/bash

if [ $# -gt 0 ]; then
	DEBUG=true
fi

source processing-functions.sh


# channel bandwidth files
for bw in $(ls bandwidth_*); do
	if [ -f $bw ]; then
		echo "$bw: $(getBandwidth $bw)"
	fi
done


for tcpd in $(ls traffic*); do
	if [ -f $tcpd ]; then
		#cat $tcpd | getTrafficPktLen > "pr.$tcpd"
		cat $tcpd | processIfstat "pr.${tcpd}_in" "pr.${tcpd}_out"
		
		# debug
		#[ $DEBUG ] && tail -v -n 5 "pr.$tcpd"
	fi
done


for mps in $(ls load_*); do
	if [ -f $mps ]; then
		cat $mps | getTimeIdle > "pr.$mps"
		
		#debug
		[ $DEBUG ] && tail -v -n 5 "pr.$mps"
	fi
done


cp logs/trafficgencl.log before_trafficgencl.log
cp logs2/trafficgencl.log after_trafficgencl.log

for clientlog in "before_trafficgencl.log" "after_trafficgencl.log"; do
	if [ -f $clientlog ]; then
		# $(date "+%d %m %Y")
		cat $clientlog | getInteractiveCli | getAverageOverS > "pr.$clientlog"
		
		# debug
		[ $DEBUG ] && tail -v -n 5 "pr.$clientlog"
	fi
done
