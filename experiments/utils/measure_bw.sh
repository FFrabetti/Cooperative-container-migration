#!/bin/bash -x
#needs input file with incidence matrix of delay values
source ./config.sh

echo "Run1"
ssh -o StrictHostKeyChecking=no root@$nodesrc "lsof -ti tcp:5201 | xargs -r kill; iperf3 -s -1 &" &
sleep 1
ssh -o StrictHostKeyChecking=no root@$nodedst "iperf3 -c $basenet$src" > bandwidthsrcdst.txt

echo "Run2"
ssh -o StrictHostKeyChecking=no root@$nodedst "lsof -ti tcp:5201 | xargs -r kill; iperf3 -s -1 &" &
sleep 1
ssh -o StrictHostKeyChecking=no root@$nodeone "iperf3 -c $basenet$dst" > bandwidthdstnode1.txt

echo "Run3"
ssh -o StrictHostKeyChecking=no root@$nodedst "lsof -ti tcp:5201 | xargs -r kill; iperf3 -s -1 &" &
sleep 1
ssh -o StrictHostKeyChecking=no root@$nodetwo "iperf3 -c $basenet$dst" > bandwidthdstnode2.txt

echo "Run4"
ssh -o StrictHostKeyChecking=no root@$nodesrc "lsof -ti tcp:5201 | xargs -r kill; iperf3 -s -1 &" &
sleep 1
ssh -o StrictHostKeyChecking=no root@$nodeclient "iperf3 -c $basenet$src" > bandwidthsrcclient.txt

echo "Run5"
ssh -o StrictHostKeyChecking=no root@$nodedst "lsof -ti tcp:5201 | xargs -r kill; iperf3 -s -1 &" &
sleep 1
ssh -o StrictHostKeyChecking=no root@$nodeclient "iperf3 -c $basenet$dst" > bandwidthdstclient.txt

