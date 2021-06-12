c#!/bin/bash

echo "Running python manage.py testing command:"
jenkins ALL=(ALL) NOPASSWD: ALL
sudo apt-get install libsqlite3-dev sqlite-devel 
./configure --enable-loadable-sqlite-extensions && make && sudo make install
