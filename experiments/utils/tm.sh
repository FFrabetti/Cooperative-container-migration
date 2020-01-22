#!/bin/bash
#set_channel takes the incidence matrix
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
bash setup_resources.sh > /dev/null
bash create_registry_all.sh > /dev/null
bash set_channel.sh < $channelparams
bash set_load.sh $srcload $dstload $node1load $node2load $loadtimeout
#ssh root@$nodesrc "local_registry.sh certs; build_trafficgen.sh $layersize $appversion"
#ssh root@$nodedst "local_registry.sh certs"
#ssh root@$nodesrc "docker tag trafficgen:$appversion $basenet$dst/trafficgen:$appversion; docker push $basenet$dst/trafficgen:$appversion; \
#		  docker tag trafficgen:${appversion}d $basenet$src/trafficgen:${appversion}d; docker push $basenet$src/trafficgen:${appversion}d"
ssh -o StrictHostKeyChecking=no root@$nodesrc "{ bash measureTrafficIn.sh & }; { bash measureTrafficOut.sh & }; bash measureLoad.sh 1 loadlocal.txt &" 
ssh -o StrictHostKeyChecking=no root@$nodedst "{ bash measureTrafficIn.sh & }; { bash measureTrafficOut.sh & }; bash measureLoad.sh 1 loadlocal.txt &"
ssh -o StrictHostKeyChecking=no root@$nodeclient "{ bash measureTrafficIn.sh & }; { bash measureTrafficOut.sh & }; bash measureLoad.sh 1 loadlocal.txt &"

