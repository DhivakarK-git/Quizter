c#!/bin/bash

echo "Running python manage.py testing command:"
export LD_LIBRARY_PATH=/usr/local/lib
python3 manage.py test quizApp/tests
