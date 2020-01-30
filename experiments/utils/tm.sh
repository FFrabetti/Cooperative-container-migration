#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

usage () {
  echo "Usage:"
  echo "   ./$(basename $0) (channelparams | '0') loadparams loadtimeout layersize appversion"
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


TT="int"
EXPDIR="tm_sl_${TT}_$(date +%F_%H-%M-%S)"
mkdir -p $EXPDIR
cp $loadparams "$EXPDIR/"
echo "$@" > "$EXPDIR/args"

if [ -f $1 ]; then
	runfromscratch=true
	cp $channelparams "$EXPDIR/"
fi

if [ $runfromscratch ]; then
	# 1. Set network interfaces + setup.sh (git pull and .sh links in bin)
	bash setup_resources.sh > setup_resources.log 2>&1

	# 1.1 /root/bin directories should have been created in all nodes
	sshroot $nodedst "[ -d /root/bin ]" || { echo "error! check setup_resources.log"; exit 1; }

	# 1.2 Check nodes and IPs
	sleep 5
	for n in $nodemaster $nodesrc $nodedst $nodeclient $nodeone $nodetwo; do
		sshroot $n "hostname; ip a show up dev $ip_if | grep 'inet '"
	done
fi

# 1.3 kill background processes from prev. runs
for n in $nodesrc $nodedst $nodeclient; do
	sshroot $n "clean_bg.sh"
done

if [ $runfromscratch ]; then
	# 2. Create and sign certificates
	bash create_certificate_all.sh > create_certificate_all.log 2>&1

	# 2.1 /root/certs directories should have been created in all nodes
	sshroot $nodedst "[ -d /root/certs ]" || { echo "error! check create_certificate_all.log"; exit 1; }

	# 3. Set channels and load baselines
	bash set_channel.sh				< $channelparams > set_channel.log 2>&1

	# 4. Measure bandwidth
	# it takes a while...
	echo "Measuring bandwidth... "
	bash measure_bw.sh
fi

bash set_load.sh $loadtimeout 	< $loadparams 	 > set_load.log 2>&1

# TODO: add a 3rd arg to build_trafficgen.sh to use MB instead of KB
sshroot $nodedst "docker rm -f \$(docker ps -q); docker system prune -fa --volumes; local_registry.sh certs;"

sshroot $nodesrc "src_build_image.sh $basenet$src $basenet$dst $appversion $layersize;
	docker container rm -f trafficgen;
	docker run -d -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -p 8080:8080 --name trafficgen trafficgen:${appversion}d;"

loadtime=1
sshrootbg $nodesrc		"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh $loadtime loadlocal.txt"
sshrootbg $nodedst		"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh $loadtime loadlocal.txt"
sshrootbg $nodeclient	"measureTraffic.sh 1 trafficin.txt $ip_if in; measureTraffic.sh 1 trafficout.txt $ip_if out; measureLoad.sh $loadtime loadlocal.txt"

echo "Sleep for a few seconds, collecting baseline traffic/load..."
sleep 10

sshroot $nodeclient "
	if [ ! -d trafficgencl ]; then
		tar -xf Cooperative-container-migration/executable/trafficgencl.tar;
		cd trafficgencl;
		docker build -t trafficgencl:1.0 .;
		cd ..;
		mkdir -p logs;
	fi"

respSize=1000
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
sshroot $nodedst "cpull_image_dest.sh https://$basenet$src trafficgen:${appversion}d https://$basenet$src https://$basenet$dst;
	docker run -d -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -p 8080:8080 --name trafficgen $basenet$dst/trafficgen:${appversion}d;"
aftermigr=$(date +%s%N)

sshrootbg $nodeclient "mkdir -p logs2;
	interactive_client.sh $respSize $prTimeFile | docker run -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro -i --rm -v \"\$(pwd)/logs2\":/logs \
	--name tgenclintdst trafficgencl:1.0 \
	java -jar trafficgencl.jar interactive http://$basenet$dst:8080/trafficgen/interactive &"
# ################################################################

echo "Sleep for a few seconds, collecting post-migration measurements..."
sleep 10

echo "$beforemigr $aftermigr" > "$EXPDIR/migr_time"

scp -r root@$nodeclient:logs "$EXPDIR/"
scp -r root@$nodeclient:logs2 "$EXPDIR/"

sshroot $nodesrc "mkdir -p srv_logs; docker cp trafficgen:/usr/local/tomcat/logs srv_logs"
scp -r root@$nodesrc:srv_logs "$EXPDIR/srv_logs_src/"

sshroot $nodedst "mkdir -p srv_logs; docker cp trafficgen:/usr/local/tomcat/logs srv_logs"
scp -r root@$nodedst:srv_logs "$EXPDIR/srv_logs_dst/"


cp setup_resources.log "$EXPDIR/"
cp create_certificate_all.log "$EXPDIR/"
cp set_channel.log "$EXPDIR/"
cp set_load.log "$EXPDIR/"
cp bandwidth* "$EXPDIR/" 	# measure_bw.sh


# these just have a packet count
# scp root@$nodesrc:trafficin.txt "$EXPDIR/trafficin_src.txt"
# scp root@$nodesrc:trafficout.txt "$EXPDIR/trafficout_src.txt"
scp root@$nodesrc:tcpdump_in "$EXPDIR/trafficin_src.txt"
scp root@$nodesrc:tcpdump_out "$EXPDIR/trafficout_src.txt"
scp root@$nodesrc:"mpstat.$loadtime.txt" "$EXPDIR/load_src.txt"

scp root@$nodedst:tcpdump_in "$EXPDIR/trafficin_dst.txt"
scp root@$nodedst:tcpdump_out "$EXPDIR/trafficout_dst.txt"
scp root@$nodedst:"mpstat.$loadtime.txt" "$EXPDIR/load_dst.txt"

scp root@$nodeclient:tcpdump_in "$EXPDIR/trafficin_cli.txt"
scp root@$nodeclient:tcpdump_out "$EXPDIR/trafficout_cli.txt"
scp root@$nodeclient:"mpstat.$loadtime.txt" "$EXPDIR/load_cli.txt"
