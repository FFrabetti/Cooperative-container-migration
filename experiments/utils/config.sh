#!/bin/bash

#conf_dir="/root/conf"
#scripts_dir="/root/mftest/scripts"

#bin_char="click"
#bin_char="gdb -batch -ex 'run' -ex 'bt' -ex 'quit' --args click"

#log_level="1"

#Netmask, assumes all subnets will use the same one
netmask="255.255.255.0"
basenet="192.168.1."

master="101"
src="102"
dst="103"
client="104"
one="105"
two="106"

nodemaster="node1-5"
nodesrc="node1-3"
nodedst="node1-4"
nodeclient="node1-1"
nodeone="node1-6"
nodetwo="node1-7"
#nodemaster="node1-8"

#Interface for the data plane
ip_if="eth0"  

# e.g. ip=$(getIp master)
function getIp {
	local name=$1;
	echo $basenet${!name}
}

backgrounddir="/tmp/background"
mkdir -p $backgrounddir

function beforeBackground {
	local fname="$backgrounddir/$1"
	[ -f "$fname" ] && kill -kill $(cat "$fname") && rm "$fname"
}

function afterBackground { # $1 := name, $2 := pid
	echo "$2" > "$backgrounddir/$1"
}

function sshroot {
	local ip=$1
	shift
	ssh -o StrictHostKeyChecking=no root@$ip $@
}
export -f sshroot

function sshrootbg {
	sshroot $@ &>/dev/null
}
export -f sshrootbg
