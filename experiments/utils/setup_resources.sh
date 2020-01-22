#!/bin/bash

source ./config.sh

echo "Setting up the nodes"

ssh root@$nodemaster "ifconfig $ip_if $basenet$master netmask $netmask up; bash setup.sh;"
ssh root@$nodesrc "ifconfig $ip_if $basenet$src netmask $netmask up; bash setup.sh;"
ssh root@$nodedst "ifconfig $ip_if $basenet$dst netmask $netmask up; bash setup.sh;"
ssh root@$nodeclient "ifconfig $ip_if $basenet$client netmask $netmask up; bash setup.sh;"
ssh root@$node1 "ifconfig $ip_if $basenet$n1 netmask $netmask up; bash setup.sh"
ssh root@$node2 "ifconfig $ip_if $basenet$n2 netmask $netmask up; bash setup.sh"



