#!/bin/bash
#needs input file with incidence matrix of delay-bw values

source config.sh || { echo "config.sh not found"; exit 1; }

#var=10ms;

function createParent {
	echo "tc qdisc del dev $ip_if root;
		tc qdisc add dev $ip_if handle 1: root htb;
		tc class add dev $ip_if parent 1: classid 1:1 htb rate 900Mbps ceil 900Mbps;"
	
	sshroot $1 "tc qdisc del dev $ip_if root;
				tc qdisc add dev $ip_if handle 1: root htb;
				tc class add dev $ip_if parent 1: classid 1:1 htb rate 900Mbps ceil 900Mbps;"
}

function doCycle {
	local f=$1
	shift

	local index=0
	while (( $# )); do
		local t=$1
		setValues $index $f ${!t} $2 $3
		index=$((index+1))
		shift
		shift
		shift
	done
}

function setValues { 	# index from to delay bw
	local i=$1
	
	echo "tc class add dev $ip_if parent 1:1 classid 1:$((i+11)) htb rate $5mbit;
				tc filter add dev $ip_if parent 1: protocol ip prio 1 u32 match ip dst $3 flowid 1:$((i+11));
				tc qdisc add dev $ip_if parent 1:$((i+11)) handle $((10*(i+1))): netem delay $4ms;"
	
	sshroot $2 "tc class add dev $ip_if parent 1:1 classid 1:$((i+11)) htb rate $5mbit;
				tc filter add dev $ip_if parent 1: protocol ip prio 1 u32 match ip dst $3 flowid 1:$((i+11));
				tc qdisc add dev $ip_if parent 1:$((i+11)) handle $((10*(i+1))): netem delay $4ms;"
}

while read from line; do
{
	createParent ${!from}
	doCycle ${!from} $line
} < /dev/null
done
