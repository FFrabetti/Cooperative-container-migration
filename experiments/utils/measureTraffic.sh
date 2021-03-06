#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

traffictime=$1
trafficfile=$2
intf=$3
direction=$4

tcpdumpfile="tcpdump_$direction"

> $tcpdumpfile

whilef=$(whileBackground "measureTraffic")
(
	prevPackets=0
	while [ -e $whilef ]; do
		countPkts=$(wc -l < $tcpdumpfile)
		curPackets=$(( countPkts - prevPackets ))
		#timestamp=$(date +%s%N)
		timestamp=$(tail -1 $tcpdumpfile | awk '{ print $1 }')
		if [ $timestamp ]; then
			echo "$timestamp,$curPackets"
		fi
		prevPackets=$countPkts
		sleep $traffictime
	done > $trafficfile
) &

tcpdump -i $intf -l --immediate-mode --direction=$direction -B 100000 -tt -U > $tcpdumpfile
