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
DPKG="dpkg --force-confold -i"

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

build_debs ()
{
    make deb
}

install_debs ()
{
    cd ${CORE}/.. || exit 127
    ${DPKG} sonm-cli_*.deb
    ${DPKG} sonm-hub_*.deb
    ${DPKG} sonm-miner_*.deb

    if [[ -n "${FULL_INSTALL}" ]]; then
        ${DPKG} sonm-marketplace_*.deb
        ${DPKG} sonm-locator_*.deb
    fi
}

restart_services ()
{
    systemctl restart sonm-hub
    systemctl restart sonm-miner

    if [[ -n "${FULL_INSTALL}" ]]; then
        systemctl restart sonm-marketplace
        systemctl restart sonm-locator
    fi
}

build_debs
install_debs
restart_services
