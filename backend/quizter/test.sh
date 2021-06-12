c#!/bin/bash

echo "Running python manage.py testing command:"
pip3 install django >3.2
python manage.py test quizApp/tests 
