#!/bin/sh

set -e

echo "##### Running tests #####"

aptos move test \
    --package-dir aptogotchi-keyless \
    --dev