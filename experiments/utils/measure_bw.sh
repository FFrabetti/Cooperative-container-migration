#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

function testbw {
	local node=$1
	local timeout=$2
	local src=$3
	local srv=$4

	if [ $# -lt 4 ]; then
		srv=$node
	fi

	ssh -f root@$node "(
		lsof -ti tcp:5201 || iperf3 -s &

		[ $timeout -eq 0 ] || { sleep $timeout
		#ps -aux | grep iperf > wokenup
		lsof -ti tcp:5201 | xargs -r kill -kill; }
	) &" &>/dev/null

	echo "end of server part" >&2

	sleep 2
	ssh root@$src "iperf3 -c $srv &
					sleep 20
					ps -C iperf3 -o pid= | xargs -r kill -kill"
}

echo "$0: $nodedst - $nodesrc"
testbw $nodedst 0 $nodesrc "$basenet$dst" > bandwidth_dst_src.txt

echo "$0: $nodedst - $nodeclient"
testbw $nodedst 0 $nodeclient "$basenet$dst" > bandwidth_dst_cli.txt

echo "$0: $nodedst - $nodeone"
testbw $nodedst 0 $nodeone "$basenet$dst" > bandwidth_dst_n1.txt

echo "$0: $nodedst - $nodetwo"
testbw $nodedst 30 $nodetwo "$basenet$dst" > bandwidth_dst_n2.txt

echo "$0: $nodeclient - $nodesrc"
testbw $nodeclient 30 $nodesrc "$basenet$client" > bandwidth_cli_src.txt
