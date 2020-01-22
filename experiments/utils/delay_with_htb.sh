#!/bin/bash

sudo tc qdisc del dev $ip_if root
tc qdisc add dev eth0 handle 1: root htb
tc class add dev eth0 parent 1: classid 1:1 htb rate 1000Mbps ceil 100Mbps
tc class add dev eth0 parent 1:1 classid 1:11 htb rate 100Mbps
tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip dst 192.168.1.101 flowid 1:11
tc qdisc add dev eth0 parent 1:11 handle 10: netem delay 10ms

