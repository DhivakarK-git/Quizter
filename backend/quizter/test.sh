c#!/bin/bash

echo "Running python manage.py testing command:"
pip3 install -r requirement.txt
pip3 install dj-database-url
python3 manage.py test quizApp/tests 
