#!/bin/bash
#needs input file with incidence matrix of delay-bw values

source config.sh || { echo "config.sh not found"; exit 1; }

#var=10ms;

function createParent {
	echo -e "$1 \n" \
"tc qdisc del dev $ip_if root;
tc qdisc add dev $ip_if root handle 1: htb;
tc class add dev $ip_if parent 1: classid 1:1 htb rate 900Mbps ceil 900Mbps;"
	
	# note: del would fail if no rule was set
	# tc qdisc show dev $ip_if
	sshroot $1 "tc qdisc del dev $ip_if root 2>/dev/null;
				tc qdisc add dev $ip_if root handle 1: htb;
				tc class add dev $ip_if parent 1: classid 1:1 htb rate 900Mbps ceil 900Mbps;"
}

function doCycle {
	local f=$1
	shift

	local index=0
	while (( $# )); do
		setValues $index $f $(getIp $1) $2 $3
		index=$((index+1))
		shift
		shift
		shift
	done
}

function setValues { 	# index from to delay bw
	local i=$1
	
	echo -e "$2 \n" \
"tc class add dev $ip_if parent 1:1 classid 1:$((i+11)) htb rate $5mbit;
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
