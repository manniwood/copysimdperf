#!/bin/bash

set -e
set -o pipefail
set -u

PGHOME=$(dirname ${BASH_SOURCE[0]})

PGRAMDATA=/run/user/1000/data

rm -rf ${PGRAMDATA}
${PGHOME}/bin/initdb --pgdata ${PGRAMDATA} --encoding=UTF8 --no-locale

