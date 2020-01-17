#!/bin/bash
> testin.txt
> trafficin.txt
tcpdump -i eth0 -l --immediate-mode --direction=in -B 100000 -tt -U >> testin.txt &
prevPackets=0
count=0
while true;
do
countPkts=$(wc -l < test.txt)
curPackets=$(( countPkts - prevPackets ))
echo $count,$curPackets >> trafficin.txt
prevPackets=$countPkts 
count=$(( count+1 ));
sleep 1;
done

#packetprocess=$!
#sleep 10;
#kill -stop $packetprocess
