#!/bin/bash
set -e

LIBRESPOT_VERSION="$1"

git clone --branch v${LIBRESPOT_VERSION} --depth 1 https://github.com/librespot-org/librespot.git librespot-code
cd librespot-code

git status

cargo build --release
