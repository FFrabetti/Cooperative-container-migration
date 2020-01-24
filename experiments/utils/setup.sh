#!/bin/bash

cd /root/Cooperative-container-migration
git reset --hard
git pull
(cd /root/Cooperative-container-migration/experiments/utils; mv setup.sh setup_git.sh) 
chmod -R +x *

cd ../

rm -rf /root/bin
mkdir -p /root/bin

find . -type f \( -name '*.sh' -o -name '*.py' \) 2>/dev/null | while read name; do
	ln -s "/root/$name" /root/bin/
	ln -sf "/root/$name" /usr/local/bin/
done
