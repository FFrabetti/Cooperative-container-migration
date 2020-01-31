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
		cat $tcpd | getTrafficPktLen > "$tcpd.pktlen"
		
		# debug
		[ $DEBUG ] && tail -v -n 5 "$tcpd.pktlen"
	fi
done


for mps in $(ls load_*); do
	if [ -f $mps ]; then
		cat $mps | getTimeIdle > "$mps.idle"
		
		#debug
		[ $DEBUG ] && tail -v -n 5 "$mps.idle"
	fi
done


cp logs/trafficgencl.log trafficgencl_before.log
cp logs2/trafficgencl.log trafficgencl_after.log

for clientlog in "trafficgencl_before.log" "trafficgencl_after.log"; do
	if [ -f $clientlog ]; then
		# $(date "+%d %m %Y")
		cat $clientlog | getInteractiveCli | getAverageOverS > "$clientlog.latency"
		
		# debug
		[ $DEBUG ] && tail -v -n 5 "$clientlog.latency"
	fi
done
