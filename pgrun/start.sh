#!/bin/bash

set -e
set -o pipefail
set -u

PGHOME=$(dirname ${BASH_SOURCE[0]})

${PGHOME}/bin/pg_ctl -D ${PGHOME}/data -l ${PGHOME}/logfile.txt start

# get pid of running postmaster
PMPID=$(head -1 ${PGHOME}/data/postmaster.pid)
# set the CPU affinity of postmaster and all of its children to a particular CPU core
taskset --cpu-list -p 5 ${PMPID}

