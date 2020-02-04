#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

usage () {
  echo "Usage:"
  echo "   ./$(basename $0) (channelparams | '0') loadparams loadtimeout layersize appversion respsize"
  exit 0
}

if [[ ( $# == "--help") ||  $# == "-h" ]]
        then
                usage
                exit 0
fi

if [ "$#" -lt 6 ]; then
  echo "Insufficient parameters!"
  usage
fi

channelparams=$1
loadparams=$2
loadtimeout=$3
layersize=$4
appversion=$5
respSize=$6

TT="int"	 # traffic type
EXPDIR="cm_sl_${TT}_$(date +%F_%H-%M-%S)"
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
	bash measure_bw.sh src client one two
fi

# 5. Set load baseline
bash set_load.sh $loadtimeout < $loadparams 2>&1 | tee set_load.log


# 6. Clean destination and run local registry
sshroot $nodedst "docker rm -f \$(docker ps -qa) 2>/dev/null;
	docker system prune -fa --volumes;
	local_registry.sh certs;
	local_registry.sh certs 7000;"

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
} | sshroot $nodesrc "src_build_image.sh $appversion $layersize;
	docker container rm -f trafficgen 2>/dev/null;
	docker run -d -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -p 8080:8080 --name trafficgen trafficgen:${appversion}d;"
				
cm_setup.sh trafficgen ${appversion}d "https://$basenet$dst:7000" "https://$basenet$src" "https://$basenet$one" "https://$basenet$two"

# 9. Measure load and traffic
sshrootbg $nodesrc		"measureLoad.sh 1 loadlocal.txt; measureTraffic.sh 1 trafficin.txt $ip_if in"
sshrootbg $nodesrc 		"measureTraffic.sh 1 trafficout.txt $ip_if out"
sshrootbg $nodedst		"measureLoad.sh 1 loadlocal.txt; measureTraffic.sh 1 trafficin.txt $ip_if in"
sshrootbg $nodedst 		"measureTraffic.sh 1 trafficout.txt $ip_if out"
sshrootbg $nodeclient	"measureLoad.sh 1 loadlocal.txt; measureTraffic.sh 1 trafficin.txt $ip_if in"
sshrootbg $nodeclient 	"measureTraffic.sh 1 trafficout.txt $ip_if out"
sshrootbg $nodeone		"measureLoad.sh 1 loadlocal.txt; measureTraffic.sh 1 trafficin.txt $ip_if in"
sshrootbg $nodeone 		"measureTraffic.sh 1 trafficout.txt $ip_if out"
sshrootbg $nodetwo		"measureLoad.sh 1 loadlocal.txt; measureTraffic.sh 1 trafficin.txt $ip_if in"
sshrootbg $nodetwo 		"measureTraffic.sh 1 trafficout.txt $ip_if out"

echo "Sleep for a few seconds, collecting baseline traffic/load..."
sleep 10

# 10. Start client container
echo "Start client container"
sshroot $nodeclient "if [ ! -d trafficgencl ]; then
		tar -xf Cooperative-container-migration/executable/trafficgencl.tar;
		cd trafficgencl;
		docker build -t trafficgencl:1.0 .;
		cd ..;
		mkdir -p logs;
	fi"

prTimeFile="pr_sequence"
if [ ! -f $prTimeFile ]; then
	# len minrange maxrange
	bash generate_rand_seq.sh 100 10 1000 > $prTimeFile
fi
cp $prTimeFile "$EXPDIR/"
scp $prTimeFile root@$nodeclient:$prTimeFile

# it runs forever, with 1s period, until the container is stopped or prTimeFile is deleted
sshrootbg $nodeclient "interactive_client.sh $respSize $prTimeFile | docker run -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -i --rm -v \"\$(pwd)/logs\":/logs \
	--name tgenclint trafficgencl:1.0 \
	java -jar trafficgencl.jar interactive http://$basenet$src:8080/trafficgen/interactive &"

echo "Sleep for a few seconds, collecting pre-migration measurements..."
sleep 10


# ################################################################
beforemigr=$(date +%s%N)
sshroot $nodedst "cpull_image_dest.sh https://$basenet$src trafficgen:${appversion}d https://$basenet$dst:7000 https://$basenet$dst;
	docker run -d -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -p 8080:8080 --name trafficgen $basenet$dst/trafficgen:${appversion}d;"
aftermigr=$(date +%s%N)

sshrootbg $nodeclient "(interactive_client.sh $respSize $prTimeFile | docker run -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -i --rm -v \"\$(pwd)/logs2\":/logs \
	--name tgenclintdst trafficgencl:1.0 \
	java -jar trafficgencl.jar interactive http://$basenet$dst:8080/trafficgen/interactive &);
	docker container rm -f tgenclint;"
# ################################################################


echo "Sleep for a few seconds, collecting post-migration measurements..."
sleep 20 	# for tcpdump weird buffered behavior...

# 11. Data collection
echo "$beforemigr $aftermigr" > "$EXPDIR/migr_time"
echo "$(((aftermigr - beforemigr) / 1000000)) ms" >> "$EXPDIR/migr_time"

scp -r root@$nodeclient:logs "$EXPDIR/"
scp -r root@$nodeclient:logs2 "$EXPDIR/"

sshroot $nodesrc "mkdir -p srv_logs; docker cp trafficgen:/usr/local/tomcat/logs srv_logs"
scp -r root@$nodesrc:srv_logs "$EXPDIR/srv_logs_src/"

sshroot $nodedst "mkdir -p srv_logs; docker cp trafficgen:/usr/local/tomcat/logs srv_logs"
scp -r root@$nodedst:srv_logs "$EXPDIR/srv_logs_dst/"

cp *.log bandwidth_*.txt "$EXPDIR/" 	# (bandwidth_*.txt from measure_bw.sh)

# these just have a packet count
# scp root@$nodesrc:trafficin.txt "$EXPDIR/trafficin_src.txt"
# scp root@$nodesrc:trafficout.txt "$EXPDIR/trafficout_src.txt"
scp root@$nodesrc:tcpdump_in "$EXPDIR/trafficin_src.txt"
scp root@$nodesrc:tcpdump_out "$EXPDIR/trafficout_src.txt"
scp root@$nodesrc:mpstat.txt "$EXPDIR/load_src.txt"

scp root@$nodedst:tcpdump_in "$EXPDIR/trafficin_dst.txt"
scp root@$nodedst:tcpdump_out "$EXPDIR/trafficout_dst.txt"
scp root@$nodedst:mpstat.txt "$EXPDIR/load_dst.txt"

scp root@$nodeclient:tcpdump_in "$EXPDIR/trafficin_cli.txt"
scp root@$nodeclient:tcpdump_out "$EXPDIR/trafficout_cli.txt"
scp root@$nodeclient:mpstat.txt "$EXPDIR/load_cli.txt"

scp root@$nodeone:tcpdump_in "$EXPDIR/trafficin_n1.txt"
scp root@$nodeone:tcpdump_out "$EXPDIR/trafficout_n1.txt"
scp root@$nodeone:mpstat.txt "$EXPDIR/load_n1.txt"

scp root@$nodetwo:tcpdump_in "$EXPDIR/trafficin_n2.txt"
scp root@$nodetwo:tcpdump_out "$EXPDIR/trafficout_n2.txt"
scp root@$nodetwo:mpstat.txt "$EXPDIR/load_n2.txt"
