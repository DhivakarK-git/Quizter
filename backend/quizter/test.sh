c#!/bin/bash

echo "Running python manage.py testing command:"
wget http://www.sqlite.org/2016/sqlite-autoconf-3150000.tar.gz
tar xvfz sqlite-autoconf-3150000.tar.gz
cd sqlite-autoconf-3150000
./configure --prefix=/usr/local
make install
