c#!/bin/bash

echo "Running python manage.py testing command:"
sudo apt-get install libsqlite3-dev sqlite-devel 
./configure --enable-loadable-sqlite-extensions && make && sudo make install
python3.9 manage.py test quizApp/tests
