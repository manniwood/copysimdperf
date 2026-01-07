#!/bin/bash

set -e
set -o pipefail
set -u


export PATH=${PATH}:/home/manni.wood/PROJECTS/FlameGraph

PG="/home/manni.wood/compiled-pg-instances/master/bin/psql -X -U manni.wood -h localhost -d postgres"

PERF="perf record -F 999 -a -g -s"

ITER=5
ROWS=5000000

echo " ======= Create table t"

${PG} <<EOF
DROP TABLE IF EXISTS t;
CREATE UNLOGGED TABLE t (id INT PRIMARY KEY, filler TEXT);
EOF


echo " ======= Text, no special characters; create /tmp/t_none.txt"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A', 4096)
FROM generate_series(1, ${ROWS}) AS s;
COPY t TO '/tmp/t_none.txt' (FORMAT text);
EOF

echo " ======= Text, no special characters; load times"

for _ in $(seq 2 ${ITER}); do
${PG} <<'EOF'
\timing
truncate table t;
\copy t from /tmp/t_none.txt
EOF
done
${PERF} -o /tmp/p1.data ${PG} <<'EOF'
\timing
truncate table t;
\copy t from /tmp/t_none.txt
EOF

rm /tmp/t_none.txt


echo " ======= CSV, no special characters; create /tmp/t_none.csv"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A', 4096)
FROM generate_series(1, ${ROWS}) AS s;
COPY t TO '/tmp/t_none.csv' (FORMAT csv, QUOTE '"');
EOF

echo " ======= CSV, no special characters; load times"

for _ in $(seq 2 ${ITER}); do
${PG} <<'EOF'
\timing
truncate table t;
\copy t from /tmp/t_none.csv (format csv)
EOF
done
${PERF} -o /tmp/p2.data ${PG} <<'EOF'
\timing
truncate table t;
\copy t from /tmp/t_none.csv (format csv)
EOF

rm /tmp/t_none.csv


echo " ======= Text, with 1/3 escapes; create /tmp/t_escape.txt"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A\\A', 1365)
FROM generate_series(1, ${ROWS}) AS s;
COPY t TO '/tmp/t_escape.txt' (FORMAT text);
EOF

echo " ======= Text, with 1/3 escapes; load times"

for _ in $(seq 2 ${ITER}); do
${PG} <<'EOF'
\timing
truncate table t;
\copy t from /tmp/t_escape.txt
EOF
done
${PERF} -o /tmp/p3.data ${PG} <<'EOF'
\timing
truncate table t;
\copy t from /tmp/t_escape.txt
EOF

rm /tmp/t_escape.txt


echo " ======= CSV, with 1/3 quotes; create /tmp/t_quote.csv"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A"A', 1365)
FROM generate_series(1, ${ROWS}) AS s;
COPY t TO '/tmp/t_quote.csv' (FORMAT csv, QUOTE '"');
EOF

echo " ======= CSV, with 1/3 quotes; load times"

for _ in $(seq 2 ${ITER}); do
${PG} <<'EOF'
\timing
truncate table t;
\copy t from /tmp/t_quote.csv (format csv)
EOF
done
${PERF} -o /tmp/p4.data ${PG} <<'EOF'
\timing
truncate table t;
\copy t from /tmp/t_quote.csv (format csv)
EOF

rm /tmp/t_quote.csv

echo " ======= Drop table t"

${PG} <<EOF
DROP TABLE IF EXISTS t;
EOF

for FILE in p1 p2 p3 p4 ; do
	perf report -i /tmp/${FILE}.data -n > /tmp/${FILE}-perf-report.txt
	perf script -i /tmp/${FILE}.data | stackcollapse-perf.pl | \
			grep ^postgres | flamegraph.pl > /tmp/${FILE}.svg
done

