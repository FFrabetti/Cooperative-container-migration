#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

traffictime=$1	#
trafficfile=$2
intf=$3
direction=$4 	#

date +%F > $trafficfile
ifstat -t -n -i $intf >> $trafficfile &
