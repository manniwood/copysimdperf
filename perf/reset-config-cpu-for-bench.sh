#!/bin/bash

set -e
set -o pipefail
set -u

if [ $(id -u) != 0 ]
then
	echo "must run this script as root" 1>&2
	exit 1
fi

TESTCORE=5

# Run the CPU at the maximum frequency, obtained from /sys/devices/system/cpu/cpuX/cpufreq/scaling_max_freq.
# (as per https://wiki.archlinux.org/title/CPU_frequency_scaling#Scaling_governors)
cpupower -c ${TESTCORE} frequency-set --governor=$(cat cpu${TESTCORE}-scaling_governor.txt)

# For CPU core ${TESTCORE},
# Disable all idle states with a equal or higher latency than 0
# (that is, disable idle).
cpupower -c ${TESTCORE} idle-set -E

# Disable setting any Turbo P-states
# (as per https://www.kernel.org/doc/html/v5.3/admin-guide/pm/intel_pstate.html)
# echo "0" | tee /sys/devices/system/cpu/intel_pstate/no_turbo

