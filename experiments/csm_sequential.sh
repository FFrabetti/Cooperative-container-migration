#!/bin/bash

# Channels: src-dst 3 cases
# - delay 0
# - delay 1 ms
# - delay 5 ms
# bandwidth measured for each case

# Volume size:
# - 100 KB
# - 1 MB
# - 10 MB
# - 100 MB

# Layer size:
# - 10 MB

# Load: 3 cases for src and dst
# Ls > Ld
# Ls < Ld
# Ls = Ld

# Traffic type:
# - just interactive traffic, for now
# trafficgen dummy application
# 	Response size:
# 	- fixed to ...
respsize=$((4 * 1024))
# 	Request rate:
# 	- min delay between requests (see interactive_client.sh)

prTimeFile="pr_sequence"
# len minrange maxrange
bash generate_rand_seq.sh 100 10 100 > $prTimeFile

loadtimeout=10000

mkdir -p args
cp Cooperative-container-migration/experiments/args/* args/


# -------- Distribute updated setup.sh --------
for n in node1-{1..8}; do
(
	scp Cooperative-container-migration/experiments/utils/setup.sh root@$n:setup.sh
	ssh root@$n "./setup.sh; apt-get -y install redis-tools;"
) & &>/dev/null
done
wait


# bash csm.sh (channelparams | '0') loadparams loadtimeout layersize appversion respsize volumesize changevol
prevchannel=""
i=0
starti=0
if [ $# -eq 1 ]; then
	starti=$1
fi

ls="10MB"
changevol=10 	# 10%
for ch in args/nodelay_ch.txt args/delay1ms_ch.txt args/delay5ms_ch.txt; do
	for vs in "100" "1MB" "10MB" "100MB"; do
		for ld in args/srchigh_load.txt args/dsthigh_load.txt args/eqmed_load.txt; do
			# check if $ld exists and start from experiment $starti
			if [ -f $ld ] && [ $i -ge $starti ]; then
			
				if [ -f $ch ] && [ $ch != "$prevchannel" ]; then
					charg=$ch
					prevchannel=$ch
				else
					charg=0
				fi
			
				echo -e "csm.sh $charg $ld $loadtimeout $ls app$ls $respsize $vs $changevol \n----------------"
				bash csm.sh $charg $ld $loadtimeout $ls "app$ls" $respsize $vs $changevol 2>&1 | tee "csm${i}.out"
				sleep 10

				# terminate all ssh connections
				ps -C ssh -o pid= | xargs -r kill -kill
				
				# ################ DEBUG ################
				# terminate after one test
				[ $# -eq 1 ] && [ $1 -eq 0 ] && exit 0
				# ################ DEBUG ################
			fi
			i=$((i+1))
		done
	done
done

# -------- Process results --------
# EXPDIR="..."
# cd $EXPDIR
# bash process_data.sh
# bash test.sh pr.* > results.txt
