c#!/bin/bash

echo "Running python manage.py testing command:"
python3.9 -m venv env
source env/bin/activate
pip3 install -r requirement.txt
