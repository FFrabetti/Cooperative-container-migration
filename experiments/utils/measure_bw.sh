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

	ssh -f root@$node "(
		lsof -ti tcp:5201 || (iperf3 -s &);

		[ $timeout -eq 0 ] || { sleep $timeout;
		lsof -ti tcp:5201 | xargs -r kill -kill; }
	) &" &>/dev/null

	echo "end of server part" >&2

	sleep 2
	ssh root@$src "date +%s%N;
		(iperf3 -c $srv $rev &);
		(sleep 20 &);
		wait -n;
		ps -C iperf3 -o pid= | xargs -r kill -kill"
}

echo "$0: $nodeclient - $nodesrc"
testbw $nodeclient 0 $nodesrc "$basenet$client" reverse > bandwidth_src_cli.txt
testbw $nodeclient 30 $nodesrc "$basenet$client" > bandwidth_cli_src.txt

while (( $# )); do
	iperfcl=$1
	node=$(getNode $iperfcl)
	
	echo "$0: $nodedst - $node"
	srv_timeout=0
	if [ $# -le 1 ]; then
		srv_timeout=30
	fi
	testbw $nodedst 0 $node "$basenet$dst" reverse > bandwidth_${iperfcl}_dst.txt
	testbw $nodedst $srv_timeout $node "$basenet$dst" > bandwidth_dst_${iperfcl}.txt

	shift
done
