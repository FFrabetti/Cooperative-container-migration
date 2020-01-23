#!/bin/bash

source ./config.sh

for v in master src dst client one two; do
	#echo ${!v};
	w="node$v";
	#echo ${!w};
	sshroot ${!w} "create_certificate.sh $basenet${!v}"
done
