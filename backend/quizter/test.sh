c#!/bin/bash

echo "Running python manage.py testing command:"
wget https://www.sqlite.org/2018/sqlite-autoconf-3240000.tar.gz
tar zxvf sqlite-autoconf-3240000.tar.gz
./configure --prefix=/usr/local
make
make install
export LD_LIBRARY_PATH=/usr/local/lib
# python3.9 -c "import sqlite3; print(sqlite3.sqlite_version)"
