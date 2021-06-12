c#!/bin/bash

echo "Running python manage.py testing command:"
export LD_LIBRARY_PATH=/usr/local/lib
python3.9 -c "import sqlite3; print(sqlite3.sqlite_version)"
sqlite3 --version 
