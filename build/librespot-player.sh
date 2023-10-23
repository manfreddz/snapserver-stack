#!/bin/bash

cd "$(dirname "$0")"
TMPBASE="/var/cache/snapcast"
mkdir -p "$TMPBASE/cache${1}"
java -cp /librespot-player.jar xyz.gianlu.librespot.player.Main \
  --deviceId="`printf %40s SnapCastLibrespot-Java-${1}|tr ' ' 'X'`" \
  --deviceName="Snapcast ${1}" \
  --player.output="STDOUT" \
  --cache.dir="$TMPBASE/cache${1}"
