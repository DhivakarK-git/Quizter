c#!/bin/bash

echo "Running python manage.py testing command:"
python3 -c "import sqlite3; print(sqlite3.sqlite_version)"
sqlite3 --version 
