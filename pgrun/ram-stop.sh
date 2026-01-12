#!/bin/bash

set -e
set -o pipefail
set -u

PGHOME=$(dirname ${BASH_SOURCE[0]})

PGRAMDATA=/run/user/1000/data

${PGHOME}/bin/pg_ctl -D ${PGRAMDATA} stop

