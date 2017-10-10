#!/bin/bash

# git is required
# go >= 1.8 is required
# packages 'debhelper devscripts dh-systemd' is required

set -ex

CWD=$(pwd)
CORE=${HOME}/go/src/github.com/sonm-io/core
GIT=$(which git)
GO=$(which go)


update_repo ()
{
    cd ${CORE} || exit
    ${GIT} reset --hard
    ${GIT} pull
}

build_debs ()
{
    GPU_SURROT=true GO=$(which go) make deb
}

install_debs ()
{
    cd ${CORE}/.. || exit
    dpkg -i *.deb
}

update_configs ()
{
    echo "[*] UPDATING CONFIGS"
    cp ${CWD}/dist-configs/hub.yaml /etc/sonm/hub-default.yaml
    cp ${CWD}/dist-configs/miner.yaml /etc/sonm/miner-default.yaml
}

restart_services ()
{
    echo "[*] RESTARTING SERVICES"
    systemctl restart sonm-hub
    systemctl restart sonm-miner
    systemctl restart sonm-marketplace
}


update_repo
build_debs
install_debs

update_configs
restart_services
