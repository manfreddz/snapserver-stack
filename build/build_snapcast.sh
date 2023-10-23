#!/bin/bash
set -e

SNAPCAST_VERSION="$1"

git clone --branch v${SNAPCAST_VERSION} --depth 1 https://github.com/badaix/snapcast.git snapcast
cd snapcast
git status
make

find . -type f

#make installserver

#make installclient
