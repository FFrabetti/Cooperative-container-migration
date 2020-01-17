#!/bin/bash
> testout.txt
> trafficout.txt
tcpdump -i eth0 -l --immediate-mode --direction=out -B 100000 -tt -U >> testout.txt &
prevPackets=0
count=0
while true;
do
countPkts=$(wc -l < test.txt)
curPackets=$(( countPkts - prevPackets ))
echo $count,$curPackets >> trafficout.txt
prevPackets=$countPkts 
count=$(( count+1 ));
sleep 1;
done

#packetprocess=$!
#sleep 10;
#kill -stop $packetprocess
