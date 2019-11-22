#!/bin/bash

# ################ Plain HTTP registry (HIGHLY INSECURE) ################
# In each node:
# 1) edit /etc/docker/daemon.json
# {
#  "insecure-registries" : ["myregistrydomain.com:5000"]
# }
#
# 2) restart Docker
# ################ ################ ################ ################


# ################ Self-signed certificate (INSECURE) ################
CN="clusterregistry"		# CN (Common Name)

# 1) generate the certificate
if [ ! -f "domain.crt" ]; then
	echo "About to generate certificate for CN=$CN ..."
	openssl req \
		-newkey rsa:4096 -nodes -sha256 \
		-x509 -days 365 \
		-keyout "domain.key" -out "domain.crt" \
		-extensions v3_ca -config san_v3_ca.cnf		# set IP SANs (Subject Alternative Names)
else
	echo "certificate domain.crt already present"
fi
# test the certificate
# openssl x509 -noout -text -in domain.crt | grep -A 1 "Subject Alternative Name"

# 2) on each node, copy certificate to /etc/docker/certs.d/$CN:5000/ca.crt
mkdir -p /etc/docker/certs.d/$CN:5000
cp domain.crt /etc/docker/certs.d/$CN:5000/ca.crt

# 3) on each node, trust the certificate at the OS level
# https://docs.docker.com/registry/insecure/#docker-still-complains-about-the-certificate-when-using-authentication
# [ubuntu]
cp domain.crt /usr/local/share/ca-certificates/$CN.crt
update-ca-certificates

# docker container stop registry
# docker container stop sec_registry && docker container rm sec_registry

# CERT_DIR=$(pwd)
# docker run -d \
	# -v "$CERT_DIR":/certs \
	# -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
	# -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
	# -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
	# -p 443:443 \
	# --restart=unless-stopped \
	# -v /home/ubu2admin/registry:/var/lib/registry \
	# --name sec_registry \
	# registry:2
# ################ ################ ################ ################
