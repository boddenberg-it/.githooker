#!/bin/bash

# some distros do not seem to like github cert
git config --global http.sslVerify false

# initial git setup - git commit fails elsewise
git config --global user.email "githooker@boddenberg.it"
git config --global user.name "githooker"

# run .githooker testsuites in dev setup
git clone https://github.com/boddenberg-it/.githooker.git 
cd .githooker && ./tests/run_tests.sh
cd ..

# run .githooker testsuites in super project
git clone https://github.com/boddenberg-it/croni && cd croni
git submodule add https://github.com/boddenberg-it/.githooker .githooker
.githooker/test --skip-prompt
