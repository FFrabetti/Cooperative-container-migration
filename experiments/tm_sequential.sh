#!/bin/bash

# Channels: src-dst 3 cases
# - delay 0
# - delay 1 ms
# - delay 5 ms
# bandwidth measured for each case

# Layer size:
# - 100 KB
# - 1 MB
# - 10 MB
# - 100 MB
# appversion has to be the same for the same layer size

# Load: 3 cases for src and dst
# Ls > Ld
# Ls < Ld
# Ls = Ld

# Traffic type:
# - just interactive traffic, for now
# trafficgen dummy application
# 	Response size:
# 	- fixed to ...
respsize=10000
# 	Request rate:
# 	- 0.5 min delay between requests

prTimeFile="pr_sequence"
# len minrange maxrange
bash generate_rand_seq.sh 100 10 500 > $prTimeFile

loadtimeout=10000

# bash tm.sh (channelparams | '0') loadparams loadtimeout layersize appversion respsize
prevchannel=""
i=0
for ch in nodelay_ch.txt delay1m_ch.txt delay5ms_ch.txt; do
	for ls in "100" "1MB" "10MB" "100MB"; do
		for ld in srchigh_load.txt dsthigh_load.txt eqmed_load.txt; do
			if [ -f $ch ] && [ $ch != $prevchannel ]; then
				charg=$ch
				prevchannel=$ch
			else
				charg=0
			fi
			
			if [ -f $ld ]; then
				echo -e "tm.sh $charg $ld $loadtimeout $ls app$ls $respsize \n----------------"
				i=$((i+1))
				bash tm.sh $charg $ld $loadtimeout $ls "app$ls" $respsize 2>&1 | tee "tm${i}.out"
				sleep 10
			fi
		done
	done
done
