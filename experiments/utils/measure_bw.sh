#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

function testbw {
	local node=$1
	local timeout=$2
	local src=$3
	local srv=$4
	local rev=""

	if [ $# -eq 5 ]; then
		rev="-R"
	fi

	ssh -f root@$node "(lsof -ti tcp:5201 || iperf3 -s) &" &>/dev/null

	if [ $timeout -gt 0 ]; then
		(sleep $timeout; ssh root@$node "lsof -ti tcp:5201 | xargs -r kill -kill") &
	fi
	
	echo "end of server part" >&2

	sleep 2
	(sleep 30; ssh root@$src "ps -C iperf3 -o pid= | xargs -r kill -kill") &
	ssh root@$src "date +%s%N; iperf3 -c $srv $rev"
	
	wait
}

echo "$0: $nodeclient - $nodesrc"
testbw $nodeclient 0 $nodesrc "$basenet$client" reverse | tee bandwidth_src_cli.txt
testbw $nodeclient 30 $nodesrc "$basenet$client" | tee bandwidth_cli_src.txt

while (( $# )); do
	iperfcl=$1
	node=$(getNode $iperfcl)
	
	echo "$0: $nodedst - $node"
	srv_timeout=0
	if [ $# -le 1 ]; then
		srv_timeout=30
	fi
	testbw $nodedst 0 $node "$basenet$dst" reverse | tee bandwidth_${iperfcl}_dst.txt
	testbw $nodedst $srv_timeout $node "$basenet$dst" | tee bandwidth_dst_${iperfcl}.txt

	shift
done
