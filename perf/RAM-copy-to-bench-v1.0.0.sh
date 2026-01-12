#!/bin/bash

set -e
set -o pipefail
set -u

export PATH=${PATH}:/home/mwood/PROJECTS/FlameGraph

PG="/home/mwood/compiled-pg-instances/master/bin/psql -X -U mwood -h localhost -d postgres"

ITER=5
ROWS=500000

echo " ======= Create table t"

${PG} <<EOF
DROP TABLE IF EXISTS t;
CREATE UNLOGGED TABLE t (id INT PRIMARY KEY, filler TEXT);
EOF


echo " ======= Text, no special characters; create /run/user/1000/t_none.txt"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A', 4096)
FROM generate_series(1, ${ROWS}) AS s;
EOF

echo " ======= Text, no special characters; dump times"

for _ in $(seq 2 ${ITER}); do
rm -f /run/user/1000/t_none.txt
${PG} <<'EOF'
\timing
\copy t to /run/user/1000/t_none.txt (format text)
EOF
done

rm -f /run/user/1000/t_none.txt


echo " ======= CSV, no special characters; create /run/user/1000/t_none.csv"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A', 4096)
FROM generate_series(1, ${ROWS}) AS s;
EOF

echo " ======= CSV, no special characters; dump times"

for _ in $(seq 2 ${ITER}); do
rm -f /run/user/1000/t_none.csv
${PG} <<'EOF'
\timing
\copy t to /run/user/1000/t_none.csv (format csv, quote '"')
EOF
done

rm -f /run/user/1000/t_none.csv


echo " ======= Text, with 1/3 escapes; create /run/user/1000/t_escape.txt"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A\\A', 1365)
FROM generate_series(1, ${ROWS}) AS s;
EOF

echo " ======= Text, with 1/3 escapes; dump times"

for _ in $(seq 2 ${ITER}); do
rm -f /run/user/1000/t_escape.txt
${PG} <<'EOF'
\timing
\copy t to /run/user/1000/t_escape.txt (format text)
EOF
done

rm -f /run/user/1000/t_escape.txt


echo " ======= CSV, with 1/3 quotes; create /run/user/1000/t_quote.csv"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A"A', 1365)
FROM generate_series(1, ${ROWS}) AS s;
EOF

echo " ======= CSV, with 1/3 quotes; dump times"

for _ in $(seq 2 ${ITER}); do
rm -f /run/user/1000/t_quote.csv
${PG} <<'EOF'
\timing
\copy t to /run/user/1000/t_quote.csv (format csv, quote '"')
EOF
done

rm -f /run/user/1000/t_quote.csv

echo " ======= Drop table t"

${PG} <<EOF
drop table if exists t;
EOF

