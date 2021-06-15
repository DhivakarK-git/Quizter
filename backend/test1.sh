c#!/bin/bash
usermod -aG docker jenkins
usermod -aG root jenkins
chmod +x /var/run/docker.sock
newgrp docker
mkdir -p .pip_cache
docker build -t djangodemo .
docker run -it -p 8020:8020 \
     djangodemo
