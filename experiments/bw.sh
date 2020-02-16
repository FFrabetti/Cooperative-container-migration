#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

channelparams=$1

EXPDIR="bw_$(date +%F_%H-%M-%S)"
mkdir -p $EXPDIR
echo "$@" > "$EXPDIR/args"
cp $channelparams "$EXPDIR/"


# 1. Set network interfaces + setup.sh (git pull and .sh links in bin)
# bash setup_resources.sh src dst client one two 2>&1 | tee setup_resources.log

# 3. Set channels
bash set_channel.sh	< $channelparams 2>&1

# 4. Measure bandwidth (client-src + $...-dst)
bash measure_bw.sh src client one two

cp bandwidth_*.txt "$EXPDIR/" 	# (bandwidth_*.txt from measure_bw.sh)
