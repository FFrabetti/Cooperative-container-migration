#!/bin/bash

if [ $# -gt 0 ]; then
	DEBUG=true
fi

source processing-functions.sh


# channel bandwidth files
bwfiles=(bandwidth_dst_src.txt bandwidth_dst_cli.txt bandwidth_dst_n1.txt bandwidth_dst_n2.txt bandwidth_cli_src.txt)

for bw in $bwfiles; do 	# $(ls bandwidth_*)
	if [ -f $bw ]; then
		echo "$bw: $(getBandwidth $bw)"
	fi
done


tcpdumpfiles=(trafficin_src.txt trafficout_src.txt trafficin_dst.txt trafficout_dst.txt trafficin_cli.txt trafficout_cli.txt)

for tcpd in $tcpdumpfiles; do 	# $(ls traffic*)
	if [ -f $tcpd ]; then
		cat $tcpd | getTrafficPktLen > "$tcpd.pktlen"
		
		# debug
		[ $DEBUG ] && tail -v -5 "$tcpd.pktlen"
	fi
done


mpstatfiles=(load_src.txt load_dst.txt load_cli.txt)

for mps in $mpstatfiles; do 	# $(ls load_*)
	if [ -f $mps ]; then
		cat $mps | getTimeIdle > "$mps.idle"
		
		#debug
		[ $DEBUG ] && tail -v -5 "$mps.idle"
	fi
done


clientlog="trafficgencl.log"
if [ -f $clientlog ]; then
	# $(date "+%d %m %Y")
	cat $clientlog | getInteractiveCli | getAverageOverS > "$clientlog.latency"
	
	# debug
	[ $DEBUG ] && tail -v -5 "$clientlog.latency"
fi
