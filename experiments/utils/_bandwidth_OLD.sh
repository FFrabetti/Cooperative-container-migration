#!/bin/bash
#needs input file with incidence matrix of delay values
source ./config.sh
ip=()
hname=()
var=10ms;
for v in master src dst client one two; do
ip+=($basenet${!v})
w1="node$v";
hname+=(${!w1})
done
echo ${ip[@]}
echo ${hname[@]}

function setDelay {
	local from=$1
	shift
	local to=0
	ssh root@${hname[$from]} "sudo tc qdisc del dev $ip_if root; tc qdisc add dev $ip_if root handle 1: prio bands 7 priomap 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1;"
	while (( $# )); do
		setUniDelay $from $to $1
		to=$((to+1))
		shift
	done
}

function setUniDelay {
	if [ $3 != "0" ]; then
	echo ${hname[$1]}
	echo "from=$1, to=$2, delay=$3"
	local to=$2
	ssh root@${hname[$1]} "tc qdisc add dev $ip_if parent 1:$((to+1)) handle $((10*(to+1))): netem delay $3ms 10;
	tc filter add dev $ip_if protocol ip parent 1: prio $((to+1)) u32 match ip dst ${ip[$2]} flowid 1:$((to+1))"
	fi
}

from=0
while read line; do
	setDelay $from $line < /dev/null
	from=$((from+1))
done
