#!/bin/bash

ipaddr=$1

if [ ! -f "certs/domain.key" ]; then
	cat Cooperative-container-migration/various/config/san_v3_ca.cnf | grep -v "IP." > san_v3.cnf
	echo "IP.1 = $ipaddr" >> san_v3.cnf
	
	mkdir -p certs

	openssl req -new -newkey rsa:4096 -nodes \
		-keyout certs/domain.key -out domain.csr \
		-extensions v3_ca -config san_v3.cnf \
		-subj "/CN=$(hostname)"
		
	openssl x509 -req -days 365 -in domain.csr \
		-CA ca_cert/ca.crt -CAkey ca_cert/ca.key -CAcreateserial \
		-out certs/domain.crt -sha256 \
		-extensions v3_ca -extfile san_v3.cnf

	rm domain.csr san_v3.cnf
fi
