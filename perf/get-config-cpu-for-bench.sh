#!/bin/bash

set -e
set -o pipefail
set -u

TESTCORE=5

cat /sys/devices/system/cpu/cpu${TESTCORE}/cpufreq/scaling_governor > cpu${TESTCORE}-scaling_governor.txt
