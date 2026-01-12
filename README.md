# Test scripts for Pg copy SIMD patch

I apply a patch to postgres and then check it in to a local git branch.
Exmaple branch name: `v4.2`.

I copy `./pgbuild/run-meson.sh` into my postgres source dir and run it. The
script tells meson to use an install prefix with the current git branch name as
one of the directory names. This allows me to apply different patches, check
those patches into different git branches, and run `./run-meson.sh` to
configure each postgres to insall in a directory named for the
currently-checked-out git branch. Exmaple installation prefix:
`/home/mwood/compiled-pg-instances/v4.2`.

After running `./run-meson.sh`, I finish the Postgres build and installation:

```
cd ${LOCATION_OF_POSTGRES_SOURCE_CODE}
cd ./build
ninja
ninja install
```

Now that postgres is installed in a directory (for instance 
`/home/mwood/compiled-pg-instances/v4.2`), I `cd` to that directory and copy these files from this repo into that directory:

```
cp ./pgrun/init.sh  /home/mwood/compiled-pg-instances/v4.2
cp ./pgrun/start.sh /home/mwood/compiled-pg-instances/v4.2
cp ./pgrun/stop.sh  /home/mwood/compiled-pg-instances/v4.2
```

From my postgres installation dir, I initialize the cluster and then start it:

```
cd /home/mwood/compiled-pg-instances/v4.2
./init.sh
./run.sh
```

Note that `run.sh` pins the postmaster (and therefore all of its children) to a single CPU core:

```
taskset --cpu-list -p 5 ${PMPID}
```

Edit `run.sh` to pin to any core you like. The assumption is that preventing a postgres process from moving cores will reduce variability in performance results.

## Install FlameGraph somewhere

Install github.com/brendangregg/FlameGraph.git somewhere on your system.

Also be sure `perf` is installed.

## Run performance script

Now that postgres is running, let's configure our chosen CPU (CPU 5 in our examples) as per Nazir's suggestions.

This repo's `./perf/config-cpu-for-bench.sh` will accomplish that. Run it as root:

```
sudo ./perf/config-cpu-for-bench.sh
```

This sets the specified CPU core to not sleep and to be in performance mode so that we get more even test results.

NOTE: Edit `./perf/config-cpu-for-bench.sh` to use whichever CPU you locked the running postgres process to above. Look for the `TESTCORE` env var in the script.

NOTE: Edit `./perf/config-cpu-for-bench.sh` to turn off turbo mode for Intel processors if you have an Intel processor. It will be the last line of the script.

Now that the CPU is set the way we like, edit `./manni-simd-copy-bench-v1.2.1.sh`'s PATH env var to match where you have installed github.com/brendangregg/FlameGraph.git. then, edit the PG env var to match where your `psql` binary is installed.

Now run the performance test, capturing its results to a file:

```
./manni-simd-copy-bench-v1.2.1.sh | tee v4.2_2026_01_07.txt
```

When the test run is done, there will also be perf artifacts in the `/tmp` directory:

```
p1.data
p1-perf-report.txt
p1.svg
p2.data
p2-perf-report.txt
p2.svg
p3.data
p3-perf-report.txt
p3.svg
p4.data
p4-perf-report.txt
p4.svg
```

Copy those to some other location so they don't get overwritten by subsequent runs.

## Running Postgres from RAM discs

In Linux, everything in the /run directory seems to be RAM discs, so use the following scripts to run postgres in RAM:

```
./pgrun/ram-init.sh
./pgrun/ram-start.sh
./pgrun/ram-stop.sh
```

To test the performance using copy files from a ram disk, I use this script:

```
TODO: get the script
./perf/RAM-manni-simd-copy-bench-v1.2.1.sh
```

# Scripts for copy to (not copy from) tests

Now that there is also a patch to test `copy to`, we need scripts to test the performance of that. I have used these:

```
./perf/RAM-copy-to-bench-v1.0.0.sh
./perf/copy-to-bench-v1.0.0.sh
```
