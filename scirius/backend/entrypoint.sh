#!/bin/bash

gunicorn -t 600 -w 4 --bind unix:/var/run/scirius/scirius.sock scirius.wsgi:application
