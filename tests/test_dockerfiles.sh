#!/bin/bash

distros=(alpine archlinux centos debian ubuntu)

for distro in ${distros[@]}; do
    docker build --no-cache -t "githooker_$distro" -f "$PWD/tests/_docker/Dockerfile.$distro" .
done
