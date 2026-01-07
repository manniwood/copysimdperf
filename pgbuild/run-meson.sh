#!/bin/bash

set -e
set -o pipefail
set -u


BRANCH=$(git branch --show-current)

# If we use `--buildtype=debugoptimized`, meson optimizes `-O2` and uses `-g`.
# Default postgres build for docker images and presumably packages like .deb and .rpm
meson setup build --prefix=/home/mwood/compiled-pg-instances/${BRANCH} --buildtype=debugoptimized

