c#!/bin/bash

echo "Running python manage.py testing command:"
python3 --version
pip install python-dateutil  
python manage.py test quizApp/tests 
