#!/bin/bash

git config --global user.name "githooker"
git config --global user.email "githooker@boddenberg.it"
docker build -f "$PWD/tests/Dockerfile.$distro" .
