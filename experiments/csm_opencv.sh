#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

usage () {
  echo "Usage:"
  echo "   ./$(basename $0) (channelparams | '0') loadparams loadtimeout layersize appversion respsize volumesize changevol"
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
loadparams=$2
loadtimeout=$3
layersize=$4
appversion=$5
respsize=$6
volumesize=$7
changevol=$8

TT="opencv"
EXPDIR="cm_sf_${TT}_$(date +%F_%H-%M-%S)"
mkdir -p $EXPDIR
cp $loadparams "$EXPDIR/"
echo "$@" > "$EXPDIR/args"

if [ -f $1 ]; then 	# channel parameters given/changed -> run from scratch
	runfromscratch=true
	cp $channelparams "$EXPDIR/"
fi


# 0. kill background processes from previous runs
for n in $nodesrc $nodedst $nodeclient $nodeone $nodetwo; do
	sshroot $n "clean_bg.sh"
done

if [ $runfromscratch ]; then
	# 1. Set network interfaces + setup.sh (git pull and .sh links in bin)
	bash setup_resources.sh src dst client one two 2>&1 | tee setup_resources.log

	# /root/bin directories should have been created
	sshroot $nodedst "[ -d /root/bin ]" || { echo "Error!"; exit 1; }

	# 2. Create and sign certificates
	for n in src dst one two; do
		node=$(getNode $n)
		ip=$(getIp $n)
		sshroot $node "create_certificate.sh $ip"
	done 2>&1 | tee create_certificate.log 

	# /root/certs directories should have been created
	sshroot $nodedst "[ -d /root/certs ]" || { echo "Error!"; exit 1; }

	# 3. Set channels
	bash set_channel.sh	< $channelparams 2>&1 | tee set_channel.log

	# 4. Measure bandwidth (client-src + $...-dst)
	# bash measure_bw.sh src client one two
fi

# 5. Set load baseline
bash set_load.sh $loadtimeout < $loadparams 2>&1 | tee set_load.log


# 6. Clean destination and run local registry
sshroot $nodedst "docker rm -f \$(docker ps -qa) 2>/dev/null;
	docker system prune -fa --volumes;
	local_registry.sh certs;
	local_registry.sh certs 7000;
	docker pull ubuntu;" # for tartovol/voltotar

sshroot $nodeone "if [ ! \$(docker ps -q --filter 'name=^sec_registry$') ]; then local_registry.sh certs; fi"
sshroot $nodetwo "if [ ! \$(docker ps -q --filter 'name=^sec_registry$') ]; then local_registry.sh certs; fi"

# 6.1 Clean client
sshroot $nodeclient "docker rm -f \$(docker ps -qa) 2>/dev/null;
	mkdir -p logs;  for f in logs/*.log; do  [ -f \$f ] && { > \$f; }; done;
	mkdir -p logs2; for f in logs2/*.log; do [ -f \$f ] && { > \$f; }; done;"

# 7. Build container image and distribute layers (push)
echo "Build container image and distribute layers"
# 8. Start container at the source
{ 	# registry imagetag (tag and push images)
	echo "$basenet$src ${appversion}d"
	echo "$basenet$dst $appversion"
	echo "$basenet$one ${appversion}b"
	echo "$basenet$two ${appversion}c"
	echo "$basenet$dst:7000 ${appversion}d"
} | sshroot $nodesrc "src_build_image.sh lanefinding $appversion $layersize python lane_finding/main.py $basenet$client solidYellowLeft.mp4;

	src_fill_volumes.sh $volumesize v1_${volumesize};
	docker pull ubuntu;

	docker container rm -f lanefinding 2>/dev/null;"

# update "master" registry with layer locations
sshroot $nodedst "cm_setup.sh lanefinding ${appversion}d https://$basenet$dst:7000 https://$basenet$src https://$basenet$one https://$basenet$two;

	docker container rm -f myredis 2>/dev/null;
	docker run -d -p 6379:6379 --name myredis redis;"

if [[ $volumesize =~ ([0-9]+)(MB) ]]; then
	num=${BASH_REMATCH[1]}
	unit=${BASH_REMATCH[2]}
	num=$((num * 1024))
else
	num=$volumesize
	unit=""	
fi
oldvsize=$((num * (100-changevol)/100))
echo "Using old cached volume size: $oldvsize KB"

# 9. Measure load and traffic
sshrootbg $nodesrc		"measureLoad.sh 1 loadlocal.txt; measureIfTraffic.sh 1 traffic.txt $ip_if"
sshrootbg $nodedst		"measureLoad.sh 1 loadlocal.txt; measureIfTraffic.sh 1 traffic.txt $ip_if"
sshrootbg $nodeclient	"measureLoad.sh 1 loadlocal.txt; measureIfTraffic.sh 1 traffic.txt $ip_if"

sshrootbg $nodeone		"measureLoad.sh 1 loadlocal.txt; measureIfTraffic.sh 1 traffic.txt $ip_if"
sshrootbg $nodetwo		"measureLoad.sh 1 loadlocal.txt; measureIfTraffic.sh 1 traffic.txt $ip_if"


# 10. Start client container
echo "Start client container"

[ -f solidYellowLeft.mp4 ] || { echo "Error: solidYellowLeft.mp4 not found"; exit 1; }
scp solidYellowLeft.mp4 root@$nodeclient:solidYellowLeft.mp4

sshrootbg $nodeclient "docker run -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
	-i --rm -v \"\$(pwd)/solidYellowLeft.mp4\":/solidYellowLeft.mp4 \
	-p 8080:8080 --name opencvclient ff185/py-simple-http:0.1 &"

echo "Sleep for a few seconds, collecting baseline traffic/load..."
sleep 10

sshroot $nodesrc "docker run -d \
		-v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
		-v v1_${volumesize}:/out \
		--name lanefinding lanefinding:${appversion}d;"

echo "Sleep for a few seconds, collecting pre-migration measurements..."
sleep 5


# ################################################################
beforemigr=$(date +%s%N)
sshroot $nodedst "csm_dest_nocp.sh $basenet$src lanefinding user1 https://$basenet$dst:7000 $basenet$dst https://$basenet$dst '-v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --name lanefinding';"
aftermigr=$(date +%s%N)
# ################################################################


echo "Sleep for a few seconds, collecting post-migration measurements..."
sleep 20

# 11. Data collection
echo "$beforemigr $aftermigr" > "$EXPDIR/migr_time"
echo "$(((aftermigr - beforemigr) / 1000000)) ms" >> "$EXPDIR/migr_time"

cp *.log bandwidth_*.txt "$EXPDIR/" 	# (bandwidth_*.txt from measure_bw.sh)

# these just have a packet count
# scp root@$nodesrc:trafficin.txt "$EXPDIR/trafficin_src.txt"
# scp root@$nodesrc:trafficout.txt "$EXPDIR/trafficout_src.txt"
#scp root@$nodesrc:tcpdump_in "$EXPDIR/trafficin_src.txt"
#scp root@$nodesrc:tcpdump_out "$EXPDIR/trafficout_src.txt"
scp root@$nodesrc:traffic.txt "$EXPDIR/traffic_src.txt"
scp root@$nodesrc:mpstat.txt "$EXPDIR/load_src.txt"

scp root@$nodedst:traffic.txt "$EXPDIR/traffic_dst.txt"
scp root@$nodedst:mpstat.txt "$EXPDIR/load_dst.txt"

scp root@$nodeclient:traffic.txt "$EXPDIR/traffic_cli.txt"
scp root@$nodeclient:mpstat.txt "$EXPDIR/load_cli.txt"

scp root@$nodeone:traffic.txt "$EXPDIR/traffic_n1.txt"
scp root@$nodeone:mpstat.txt "$EXPDIR/load_n1.txt"
scp root@$nodetwo:traffic.txt "$EXPDIR/traffic_n2.txt"
scp root@$nodetwo:mpstat.txt "$EXPDIR/load_n2.txt"
