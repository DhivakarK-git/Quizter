c#!/bin/bash
usermod -aG docker jenkins
usermod -aG root jenkins
chmod 664 /var/run/docker.sock
mkdir -p .pip_cache
docker build -t djangodemo .
docker run -it -p 8020:8020 \
     djangodemo
