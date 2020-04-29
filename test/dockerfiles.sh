#!/bin/bash

distros=(debian ubuntu archlinux)

for distro in ${distros[@]}; do
    docker build -t "githooker_$distro" -f test/Dockerfile.$distro .
done