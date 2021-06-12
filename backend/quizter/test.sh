c#!/bin/bash

echo "Running python manage.py testing command:"
export LD_LIBRARY_PATH=/usr/local/lib
pip3.9 install sqlite3
python3.9 -c "import sqlite3; print(sqlite3.sqlite_version)"
sqlite3 --version 
