#!/bin/bash

source ./config.sh

traffictime=$1
trafficfile=$2
intf=$3
direction=$4

tcpdumpfile="tcpdump_$direction"

tcpdump -i $intf -l --immediate-mode --direction=$direction -B 100000 -tt -U > $tcpdumpfile &
runningBackground "tcpdump"

whilef=$(whileBackground "measureTraffic")
(
	prevPackets=0
	while [ -e $whilef ]; do
		countPkts=$(wc -l < $tcpdumpfile)
		curPackets=$(( countPkts - prevPackets ))
		echo $(date +%s%N),$curPackets
		prevPackets=$countPkts
		sleep $traffictime
	done > $trafficfile
) &