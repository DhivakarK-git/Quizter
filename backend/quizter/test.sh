c#!/bin/bash

echo "Running python manage.py testing command:"
python3.9 -v
flutter doctor -v

python3.9 manage.py test quizApp/tests
docker --version
docker-compose --version

