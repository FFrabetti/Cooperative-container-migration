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
