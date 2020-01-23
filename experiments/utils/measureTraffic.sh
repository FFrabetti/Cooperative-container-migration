#!/bin/bash

source ./config.sh

traffictime=$1
trafficfile=$2
intf=$3
direction=$4

tcpdumpfile="tcpdump_$direction"

beforeBackground "measureTraffic_$direction.pid"
tcpdump -i $intf -l --immediate-mode --direction=$direction -B 100000 -tt -U > $tcpdumpfile &
afterBackground "measureTraffic_$direction.pid" $!

beforeBackground "measureTraffic_$direction_time.pid"
(
	prevPackets=0
	while true; do
		countPkts=$(wc -l < $tcpdumpfile)
		curPackets=$(( countPkts - prevPackets ))
		echo $(date +%s%N),$curPackets
		prevPackets=$countPkts
		sleep $traffictime
	done > $trafficfile
) &
afterBackground "measureTraffic_$direction_time.pid" $!
