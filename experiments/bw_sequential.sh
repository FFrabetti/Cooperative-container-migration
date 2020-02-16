#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

mkdir -p args
cp Cooperative-container-migration/experiments/args/* args/


# -------- Distribute updated setup.sh --------
for n in node1-{1..8}; do
(
	scp Cooperative-container-migration/experiments/utils/setup.sh root@$n:setup.sh
	ssh root@$n "./setup.sh"
) & &>/dev/null
done
wait


bash setup_resources.sh src dst client one two 2>&1 | tee setup_resources.log

for i in {1..10}; do
	for ch in args/nodelay_ch.txt args/delay1ms_ch.txt args/delay5ms_ch.txt; do
		bash bw.sh $ch 2>&1
		
		sleep 5
		
		# terminate all ssh connections
		ps -C ssh -o pid= | xargs -r kill -kill		
	done
done
