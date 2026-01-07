#!/bin/bash

set -e
set -o pipefail
set -u

PGHOME=$(dirname ${BASH_SOURCE[0]})

${PGHOME}/bin/pg_ctl -D ${PGHOME}/data stop

