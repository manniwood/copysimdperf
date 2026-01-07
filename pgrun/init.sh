#!/bin/bash

set -e
set -o pipefail
set -u

PGHOME=$(dirname ${BASH_SOURCE[0]})

${PGHOME}/bin/initdb --pgdata ${PGHOME}/data --encoding=UTF8 --no-locale

