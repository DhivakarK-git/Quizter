c#!/bin/bash

echo "Running python manage.py testing command:"
pip3.9 install django-cors-headers django-graphql-auth graphene-django pillow whitenoise django-graphene-permissions
python3.9 manage.py test quizApp/tests
