#!/bin/bash

cd /root/Cooperative-container-migration 
git pull
cd ../
mkdir -p /root/bin
find . -type f \( -name '*.sh' -o -name '*.py' \) 2>/dev/null | while read name; do
	ln -s "/root/$name" /root/bin/
done
