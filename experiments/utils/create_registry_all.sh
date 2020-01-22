#!/bin/bash
source ./config.sh

for v in master src dst client one two; do
#echo ${!v};
w="node$v";
#echo ${!w};
ssh root@${!w} "cat Cooperative-container-migration/various/config/san_v3_ca.cnf | grep -v \"IP.\" > \"\$(hostname).cnf\";
		      echo \"IP.1 = $basenet${!v}\" >> \"\$(hostname).cnf\"; 
		      mkdir -p certs;
		      openssl req -new -newkey rsa:4096 -nodes \
	              -keyout certs/domain.key -out domain.csr \
	              -extensions v3_ca -config \"\$(hostname).cnf\" \
	              -subj \"/CN=\$(hostname)\";
		      openssl x509 -req -days 365 -in domain.csr \
	              -CA ca_cert/ca.crt -CAkey ca_cert/ca.key -CAcreateserial \
	              -out certs/domain.crt -sha256 \
	              -extensions v3_ca -extfile \"\$(hostname).cnf\";
		      rm domain.csr"
done
