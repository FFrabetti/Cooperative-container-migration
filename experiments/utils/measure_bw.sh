#!/bin/bash -x

source ./config.sh

startserver="(lsof -ti tcp:5201 | xargs -r kill; iperf3 -s -1) &"

echo "$0: $nodedst - $nodesrc"
sshrootbg $nodesrc "$startserver"
sleep 1
sshroot $nodedst "iperf3 -c $basenet$src" > bandwidth_src_dst.txt

echo "$0: $nodeone - $nodedst"
sshrootbg $nodedst "$startserver"
sleep 1
sshroot $nodeone "iperf3 -c $basenet$dst" > bandwidth_dst_node1.txt

echo "$0: $nodetwo - $nodedst"
sshrootbg $nodedst "$startserver"
sleep 1
sshroot $nodetwo "iperf3 -c $basenet$dst" > bandwidth_dst_node2.txt

echo "$0: $nodeclient - $nodesrc"
sshrootbg $nodesrc "$startserver"
sleep 1
sshroot $nodeclient "iperf3 -c $basenet$src" > bandwidth_src_client.txt

echo "$0: $nodeclient - $nodedst"
sshrootbg $nodedst "$startserver"
sleep 1
sshroot $nodeclient "iperf3 -c $basenet$dst" > bandwidth_dst_client.txt
