#!/bin/bash
#needs input file with incidence matrix of delay-bw values

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

function setValues {
	local from=$1
	shift
	local to=0
	ssh root@${hname[$from]} "sudo tc qdisc del dev $ip_if root; tc qdisc add dev $ip_if handle 1: root htb; tc class add dev $ip_if parent 1: classid 1:1 htb rate 900Mbps ceil 900Mbps;"
	while (( $# )); do
		local delay=$(echo $1 | cut -d '-' -f1)
		local bw=$(echo $1 | cut -d '-' -f2) 
		setUniValues $from $to $delay $bw
		to=$((to+1))
		shift
	done
}

function setUniValues {
	if [ $3 != "0" ]; then
	echo ${hname[$1]}
	echo "from=$1, to=$2, delay=$3"
	local to=$2
	ssh root@${hname[$1]} "tc class add dev $ip_if parent 1:1 classid 1:$((to+11)) htb rate $4mbit;
			       tc filter add dev $ip_if parent 1: protocol ip prio 1 u32 match ip dst ${ip[$2]} flowid 1:$((to+11));
			       tc qdisc add dev $ip_if parent 1:$((to+11)) handle $((10*(to+1))): netem delay $3ms;"
	fi
}

from=0
while read line; do
	setValues $from $line < /dev/null
	from=$((from+1))
done
