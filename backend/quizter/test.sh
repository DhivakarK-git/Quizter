c#!/bin/bash

echo "Running python manage.py testing command:"
pip3 install -r requirement.txt
pip3 install python-dateutil  
python3 manage.py test quizApp/tests 
