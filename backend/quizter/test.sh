c#!/bin/bash

echo "Running python manage.py testing command:"
source env/bin/activate
python3.9 manage.py test quizApp/tests
