c#!/bin/bash

echo "Running python manage.py testing command:"
sudo apt install python3-pip
pip3 install python-dateutil  
python3 manage.py test quizApp/tests 
