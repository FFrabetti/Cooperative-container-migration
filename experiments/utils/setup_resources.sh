#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

echo "Setting up the nodes"

while (( $# )); do
	node=$(getNode $1)
	ip=$(getIp $1)
	sshroot $node "ifconfig $ip_if $ip netmask $netmask up;
		./setup.sh;
		sleep 2;
		echo \$(hostname): \$(ip a show up dev $ip_if | grep 'inet ');
	" &
	
	shift
done

wait
