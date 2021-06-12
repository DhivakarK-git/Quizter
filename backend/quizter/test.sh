c#!/bin/bash

echo "Running python manage.py testing command:"
python3 --version
pip3 install python-dateutil  
python3 manage.py test quizApp/tests 
