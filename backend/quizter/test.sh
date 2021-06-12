c#!/bin/bash

echo "Running python manage.py testing command:"
python3.9 -v
# pip3.9 install dj-database-url

python3 manage.py test quizApp/tests
