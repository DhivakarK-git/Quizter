c#!/bin/bash

echo "Running python manage.py testing command:"
pip install python-dateutil  
python manage.py test quizApp/tests 
