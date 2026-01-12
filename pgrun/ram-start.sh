#!/bin/bash

set -e
set -o pipefail
set -u

PGHOME=$(dirname ${BASH_SOURCE[0]})

PGRAMDATA=/run/user/1000/data

TESTCORE=27

${PGHOME}/bin/pg_ctl -D ${PGRAMDATA} -l ${PGHOME}/logfile.txt start

# get pid of running postmaster
PMPID=$(head -1 ${PGRAMDATA}/postmaster.pid)
# set the CPU affinity of postmaster and all of its children to a particular CPU core
taskset --cpu-list -p ${TESTCORE} ${PMPID}

