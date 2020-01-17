#!/bin/bash
cd /root/Cooperative-container-migration 
git pull
cd ../
mkdir /root/bin
find . -type f -name "*.sh" | while read name; do ln -s "/root/$name" /root/bin/; done;

