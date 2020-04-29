#!/bin/bash

git config --global user.name "githooker"
git config --global user.email "githooker@boddenberg.it"
docker build -f "$PWD/test/Dockerfile.$distro" .
