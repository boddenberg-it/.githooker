#!/bin/bash

# some distros do not seem to like github cert
git config --global http.sslVerify false ;\
# initial git setup - git commit fails elsewise
git config --global user.email "githooker@boddenberg.it" ;\
git config --global user.name "githooker" ;\

# run .githooker testsuites dev setup
git clone https://github.com/boddenberg-it/.githooker.git 
cd .githooker && ./tests/run_tests.sh
cd ..

# run .githookertestsutes in super project
git clone https://github.com/boddenberg-it/croni && cd croni
git submodule add https://github.com/boddenberg-it/.githooker .githooker
echo "yes" | .githooker/test
