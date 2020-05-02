#!/bin/bash

# some distros do not seem to like github cert
git config --global http.sslVerify false ;\
# initial git setup - git commit fails elsewise
git config --global user.email "githooker@boddenberg.it" ;\
git config --global user.name "githooker" ;\

git clone https://github.com/boddenberg-it/.githooker.git 

cd .githooker && ./tests/run_tests.sh