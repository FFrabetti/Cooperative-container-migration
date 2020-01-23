#!/bin/bash

source ./config.sh

echo "Setting up the nodes"

sshroot $nodemaster		"ifconfig $ip_if $basenet$master netmask $netmask up;	setup.sh"
sshroot $nodesrc		"ifconfig $ip_if $basenet$src netmask $netmask up;		setup.sh"
sshroot $nodedst		"ifconfig $ip_if $basenet$dst netmask $netmask up;		setup.sh"
sshroot $nodeclient		"ifconfig $ip_if $basenet$client netmask $netmask up;	setup.sh"
sshroot $node1			"ifconfig $ip_if $basenet$n1 netmask $netmask up;		setup.sh"
sshroot $node2			"ifconfig $ip_if $basenet$n2 netmask $netmask up;		setup.sh"
