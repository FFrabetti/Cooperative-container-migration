#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

echo "Setting up the nodes"

sshroot $nodemaster		"ifconfig $ip_if $basenet$master netmask $netmask up;	./setup.sh"
sshroot $nodesrc		"ifconfig $ip_if $basenet$src netmask $netmask up;		./setup.sh"
sshroot $nodedst		"ifconfig $ip_if $basenet$dst netmask $netmask up;		./setup.sh"
sshroot $nodeclient		"ifconfig $ip_if $basenet$client netmask $netmask up;	./setup.sh"
sshroot $nodeone		"ifconfig $ip_if $basenet$one netmask $netmask up;		./setup.sh"
sshroot $nodetwo		"ifconfig $ip_if $basenet$two netmask $netmask up;		./setup.sh"
