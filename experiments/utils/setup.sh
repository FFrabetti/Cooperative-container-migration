#!/bin/bash

rm -rf /root/bin
cd /root/Cooperative-container-migration
git reset --hard
git pull
(cd /root/Cooperative-container-migration/experiments/utils; mv setup.sh setup_git.sh) 
chmod -R +x *
cd ../
mkdir -p /root/bin
find . -type f \( -name '*.sh' -o -name '*.py' \) 2>/dev/null | while read name; do
	ln -s "/root/$name" /root/bin/
done
