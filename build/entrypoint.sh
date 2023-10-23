#!/bin/bash
set -e

echo "Entering snapcast entrypoint.sh ($0 $@)"

DEFAULT_ARGUMENTS=""

arguments="$@"
[ "$arguments" == "" ] && arguments="$DEFAULT_ARGUMENTS" || arguments="$arguments $DEFAULT_ARGUMENTS"

if [[ $# == 0 || $1 == -* ]]; then
    echo exec snapserver $arguments
    exec snapserver $arguments
else
    exec "$@"
fi
