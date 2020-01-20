# Configure the Registry for TLS #

1.  Create your CA key and certificate
    ```
	mkdir -p ca_certs
    openssl req \
      -newkey rsa:4096 -nodes -sha256 -keyout ca_certs/ca.key \
      -x509 -days 365 -out ca_certs/ca.crt
    ```

    When requested for a Common Name (CN), give the _hostname_ of the node.

2.  Copy them to **every node** and make Docker and the host OS to trust them

	```
	sudo mkdir -p /etc/docker/certs.d/<CN>:5000
	sudo cp ca_certs/ca.crt /etc/docker/certs.d/<CN>:5000/ca.crt

	sudo cp ca_certs/ca.crt /usr/local/share/ca-certificates/<CN>.crt
	sudo update-ca-certificates
	```
	(Remember to change `<CN>`)

3.  Create a Certificate Signing Request, using the node (the one where the Registry will be running) hostname as CN and its IP address
	
	```
	cat san_v3_ca.cnf | grep -v "IP." > "$(hostname).cnf"
	echo "IP.1 = <IP>" >> "$(hostname).cnf"

	mkdir -p certs
	openssl req -new -newkey rsa:4096 -nodes \
		-keyout certs/domain.key -out domain.csr \
		-extensions v3_ca -config "$(hostname).cnf" \
		-subj "/CN=$(hostname)"
	```
	(Remember to change `<IP>`)

4.  Sign the certificate (using the CA key)

	```
	openssl x509 -req -days 365 -in domain.csr \
		-CA ca_certs/ca.crt -CAkey ca_certs/ca.key -CAcreateserial \
		-out certs/domain.crt -sha256 \
		-extensions v3_ca -extfile "$(hostname).cnf"
	```

	Test the presence of the extensions
	```
	openssl x509 -in certs/domain.crt -text -noout | less
	```
	
	(To test the CSR, use instead the following)
	```
	openssl req -verify -in domain.csr -text -noout | less
	```

5.  Run a secure Registry and test it

	```
	docker run -d -p 443:443 -v "$(pwd)/certs":/certs \
		-e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
		-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
		-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
		--name sec_registry registry

	curl "https://<IP>/v2/"
	curl "https://$(hostname)/v2/"
	```

### References ###
- [Deploy a registry server | Docker Documentation](https://docs.docker.com/registry/deploying/)
- [Test an insecure registry | Docker Documentation](https://docs.docker.com/registry/insecure/)
- [OpenSSL Quick Reference Guide | DigiCert.com](https://www.digicert.com/ssl-support/openssl-quick-reference-guide.htm)
