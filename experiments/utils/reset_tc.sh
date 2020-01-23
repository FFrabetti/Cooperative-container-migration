#!/bin/bash

source ./config.sh

for v in master src dst client one two; do
	w1="node$v";
	hname=${!w1}
	sshroot $hname "sudo tc qdisc del dev $ip_if root"
done
