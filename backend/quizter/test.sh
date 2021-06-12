c#!/bin/bash

echo "Running python manage.py testing command:"
source env/bin/activate
sudo apt-get install python3.9-pip
pip3.9 -v
# pip3 install django
# python3.9 manage.py test quizApp/tests
