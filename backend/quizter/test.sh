c#!/bin/bash

echo "Running python manage.py testing command:"
pip3.9 install django
python3.9 manage.py test quizApp/tests
