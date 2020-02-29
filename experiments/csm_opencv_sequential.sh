#!/bin/bash

# Channels: src-dst
# - delay 0
# - delay 5 ms
# bandwidth measured for each case

# Volume size:
# - 10 MB

# Layer size:
# - 10 MB

# Load: src and dst
# Ls = Ld

respsize=0
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
if [ $# -ge 1 ]; then
	starti=$1
fi

ls="10MB"
changevol=10 	# 10%
for ch in args/nodelay_ch.txt args/delay5ms_ch.txt; do
	for vs in "10MB"; do
		for ld in args/eqmed_load.txt; do
			echo "i=$i"
			# check if $ld exists and start from experiment $starti
			if [ -f $ld ] && [ $i -ge $starti ] && ([ $# -ne 2 ] || [ $i -le $2 ]); then
			
				if [ -f $ch ] && [ $ch != "$prevchannel" ]; then
					charg=$ch
					prevchannel=$ch
				else
					charg=0
				fi
			
				echo -e "csm_opencv.sh $charg $ld $loadtimeout $ls app$ls $respsize $vs $changevol \n----------------"
				bash csm_opencv.sh $charg $ld $loadtimeout $ls "app$ls" $respsize $vs $changevol 2>&1 | tee "csm_opencv${i}.out"
				sleep 10

				# terminate all ssh connections
				ps -C ssh -o pid= | xargs -r kill -kill
				
				# ################ DEBUG ################
				# terminate after one test
				[ $# -eq 1 ] && [ $1 -eq 0 ] && exit 0
				# ################ DEBUG ################
			fi
			echo "-------- END i=$i --------"
			i=$((i+1))
		done
	done
done

# -------- Process results --------
# EXPDIR="..."
# cd $EXPDIR
# bash process_data.sh
# bash test.sh pr.* > results.txt
