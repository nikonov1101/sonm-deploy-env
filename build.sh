#!/bin/bash

# git is required
# go >= 1.8 is required
#
# requirements to build .deb packages
# apt-get install debhelper devscripts dh-systemd -y
#
# requirements to build Worker with GPU support
# apt-get install opencl-headers nvidia-opencl-dev --no-install-recommends

set -ex

CWD=$(pwd)
CORE=${HOME}/go/src/github.com/sonm-io/core
GIT=$(which git)

# Build with GPU support
GPU_SURROT=true

if [[ -z $(which go) ]];
then
    # fallback to typical install path for linux systems
    export GO="/usr/local/go/bin/go"
else
    # or use obtained path
    export GO=$(which go)
fi

update_repo ()
{
    cd ${CORE} || exit 127
    ${GIT} reset --hard
    ${GIT} pull
}

build_debs ()
{
    make deb
}

install_debs ()
{
    cd ${CORE}/.. || exit 127
    dpkg -i sonm-cli_*.deb
    dpkg -i sonm-hub_*.deb
    dpkg -i sonm-miner_*.deb

    if [[ -n "${FULL_INSTALL}" ]]; then
        dpkg -i sonm-marketplace_*.deb
        # dpkg -i sonm-locator_*.deb
    fi
}

update_configs ()
{
    cp ${CWD}/dist-configs/hub.yaml /etc/sonm/hub-default.yaml
    cp ${CWD}/dist-configs/miner.yaml /etc/sonm/miner-default.yaml
}

restart_services ()
{
    systemctl restart sonm-hub
    systemctl restart sonm-miner

    if [[ -n "${FULL_INSTALL}" ]]; then
        systemctl restart sonm-marketplace
        # systemctl restart sonm-locator
    fi
}


update_repo
build_debs
install_debs

update_configs
restart_services
