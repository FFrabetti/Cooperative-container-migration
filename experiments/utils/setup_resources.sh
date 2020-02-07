#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

echo "Setting up the nodes"

cmdargs="$@"

while (( $# )); do
	node=$(getNode $1)
	ip=$(getIp $1)
	sshroot $node "ifconfig $ip_if $ip netmask $netmask up;
		[ -d bin ] || ./setup.sh;
		sleep 2;
		echo \$(hostname): \$(ip a show up dev $ip_if | grep 'inet ');
	" &
	
	shift
done

wait

for n in $cmdargs; do
	nodeip=$(getNode $n)
	sshroot $nodeip "for ip in $src $dst $client $one $two; do
		mkdir -p \$HOME/.ssh;
		if [ -z \"\$(ssh-keygen -F $basenet\$ip)\" ]; then
			ssh-keyscan -H $basenet\$ip >> \$HOME/.ssh/known_hosts;
		fi;
	done"
done
