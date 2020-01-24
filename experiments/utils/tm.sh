#!/bin/bash

source ./config.sh

usage () {
  echo "Usage:"
  echo "   ./$(basename $0) channelparams loadparams loadtimeout layersize appversion"
  exit 0
}

if [[ ( $# == "--help") ||  $# == "-h" ]]
        then
                usage
                exit 0
fi

if [ "$#" -lt 5 ]; then
  echo "Insufficient parameters!"
  usage
fi

channelparams=$1
loadparams=$2
loadtimeout=$3
layersize=$4
appversion=$5


NTW=1
WL=1
TT="int"
EXPDIR="tm_sl_ntw$NTW_wl$WL_$TT_$(date +%F_%H-%M-%S)"
mkdir -p $EXPDIR
cp $channelparams "$EXPDIR/"
cp $loadparams "$EXPDIR/"
echo "$@" > "$EXPDIR/args"


# 1. Set network interfaces + setup.sh (git pull and .sh links in bin)
setup_resources.sh > setup_resources.log 2>&1

# 1.1 /root/bin directories should have been created in all nodes
sshroot $nodedst "[ -d /root/bin ]" || { echo "error! check setup_resources.log"; exit 1; }

# 1.2 Check nodes and IPs + kill background processes from prev. runs
sleep 5
for n in $nodemaster $nodesrc $nodedst $nodeclient $nodeone $nodetwo; do
	sshroot $n "hostname; ip a show up dev $ip_if | grep 'inet '; clean_bg.sh"
done

# 2. Create and sign certificates
create_certificate_all.sh > create_certificate_all.log 2>&1

# 2.1 /root/certs directories should have been created in all nodes
sshroot $nodedst "[ -d /root/certs ]" || { echo "error! check create_certificate_all.log"; exit 1; }

# 3. Set channels and load baselines
set_channel.sh				< $channelparams > set_channel.log 2>&1
set_load.sh $loadtimeout 	< $loadparams 	 > set_load.log 2>&1

# 4. Measure bandwidth
# it takes a while...
echo "Measuring bandwidth... "
measure_bw.sh


#ssh root@$nodesrc "local_registry.sh certs; build_trafficgen.sh $layersize $appversion"
#ssh root@$nodedst "local_registry.sh certs"
#ssh root@$nodesrc "docker tag trafficgen:$appversion $basenet$dst/trafficgen:$appversion; docker push $basenet$dst/trafficgen:$appversion; \
#		  docker tag trafficgen:${appversion}d $basenet$src/trafficgen:${appversion}d; docker push $basenet$src/trafficgen:${appversion}d"


sshrootbg $nodesrc		"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh 1 loadlocal.txt"
sshrootbg $nodedst		"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh 1 loadlocal.txt"
sshrootbg $nodeclient	"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh 1 loadlocal.txt"


# ################################################################
sleep 10
# ################################################################


cp setup_resources.log "$EXPDIR/"
cp create_certificate_all.log "$EXPDIR/"
cp set_channel.log "$EXPDIR/"
cp set_load.log "$EXPDIR/"
cp bandwidth* "$EXPDIR/" 	# measure_bw.sh


scp $nodesrc:trafficin.txt "$EXPDIR/trafficin_src.txt"
scp $nodesrc:trafficout.txt "$EXPDIR/trafficout_src.txt"
scp $nodesrc:loadlocal.txt "$EXPDIR/load_src.txt"

scp $nodedst:trafficin.txt "$EXPDIR/trafficin_dst.txt"
scp $nodedst:trafficout.txt "$EXPDIR/trafficout_dst.txt"
scp $nodedst:loadlocal.txt "$EXPDIR/load_dst.txt"

scp $nodeclient:trafficin.txt "$EXPDIR/trafficin_dst.txt"
scp $nodeclient:trafficout.txt "$EXPDIR/trafficout_dst.txt"
scp $nodeclient:loadlocal.txt "$EXPDIR/load_dst.txt"
