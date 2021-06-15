c#!/bin/bash
mkdir -p .pip_cache
docker build -t djangodemo .
docker run -it -p 8020:8020 \
     djangodemo
