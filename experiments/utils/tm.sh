#!/bin/bash

source ./config.sh

usage () {
  echo "Usage:"
  echo "   ./$(basename $0) channelparams srcload dstload node1load node2load loadtimeout layersize appversion"
  exit 0
}

if [[ ( $# == "--help") ||  $# == "-h" ]]
        then
                usage
                exit 0
fi

if [ "$#" -lt 8 ]; then
  echo "Insufficient parameters!"
  usage
fi

channelparams=$1
srcload=$2
dstload=$3
node1load=$4
node2load=$5
loadtimeout=$6
layersize=$7
appversion=$8

# 1. Set network interfaces + setup.sh (git pull and .sh links in bin)
setup_resources.sh > setup_resources.log 2>&1

# 1.1 Check nodes and IPs
sleep 5
ipup="ip a show up dev $ip_if | grep 'inet '"
echo "Master"
sshroot $nodemaster		"hostname; $ipup"
echo "Source"
sshroot $nodesrc		"hostname; $ipup"
echo "Destination"
sshroot $nodedst		"hostname; $ipup"
echo "Client"
sshroot $nodeclient		"hostname; $ipup"
echo "Neighbor1"
sshroot $node1			"hostname; $ipup"
echo "Neighbor2"
sshroot $node2			"hostname; $ipup"

# 2. Create and sign certificates
create_certificate_all.sh > create_certificate_all.log 2>&1

# 3. Set channels and load baselines
set_channel.sh				< $channelparams > set_channel.log 2>&1
set_load.sh $loadtimeout 	< $loadparams 	 > set_load.log 2>&1

# 4. Measure bandwidth
# it takes a while...
rm bandwidth*
beforeBackground "measure_bw.pid"
measure_bw.sh &
afterBackground "measure_bw.pid" $!

echo "Measuring bandwidth... wait for 30 s"
sleep 30
[ $(ls bandwidth* | wc -w) -eq 5 ] || { echo "Error in measuring bandwidth"; exit 1; }


#ssh root@$nodesrc "local_registry.sh certs; build_trafficgen.sh $layersize $appversion"
#ssh root@$nodedst "local_registry.sh certs"
#ssh root@$nodesrc "docker tag trafficgen:$appversion $basenet$dst/trafficgen:$appversion; docker push $basenet$dst/trafficgen:$appversion; \
#		  docker tag trafficgen:${appversion}d $basenet$src/trafficgen:${appversion}d; docker push $basenet$src/trafficgen:${appversion}d"


sshrootbg $nodesrc		"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh 1 loadlocal.txt"
sshrootbg $nodedst		"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh 1 loadlocal.txt"
sshrootbg $nodeclient	"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh 1 loadlocal.txt"
