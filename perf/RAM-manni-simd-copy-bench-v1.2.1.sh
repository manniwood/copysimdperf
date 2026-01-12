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
COPY t TO '/run/user/1000/t_none.txt' (FORMAT text);
EOF

echo " ======= Text, no special characters; load times"

for _ in $(seq 2 ${ITER}); do
${PG} <<'EOF'
\timing
truncate table t;
\copy t from /run/user/1000/t_none.txt
EOF
done

rm /run/user/1000/t_none.txt


echo " ======= CSV, no special characters; create /run/user/1000/t_none.csv"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A', 4096)
FROM generate_series(1, ${ROWS}) AS s;
COPY t TO '/run/user/1000/t_none.csv' (FORMAT csv, QUOTE '"');
EOF

echo " ======= CSV, no special characters; load times"

for _ in $(seq 2 ${ITER}); do
${PG} <<'EOF'
\timing
truncate table t;
\copy t from /run/user/1000/t_none.csv (format csv)
EOF
done

rm /run/user/1000/t_none.csv


echo " ======= Text, with 1/3 escapes; create /run/user/1000/t_escape.txt"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A\\A', 1365)
FROM generate_series(1, ${ROWS}) AS s;
COPY t TO '/run/user/1000/t_escape.txt' (FORMAT text);
EOF

echo " ======= Text, with 1/3 escapes; load times"

for _ in $(seq 2 ${ITER}); do
${PG} <<'EOF'
\timing
truncate table t;
\copy t from /run/user/1000/t_escape.txt
EOF
done

rm /run/user/1000/t_escape.txt


echo " ======= CSV, with 1/3 quotes; create /run/user/1000/t_quote.csv"

${PG} <<EOF
truncate t;
INSERT INTO t
SELECT s, repeat('A"A', 1365)
FROM generate_series(1, ${ROWS}) AS s;
COPY t TO '/run/user/1000/t_quote.csv' (FORMAT csv, QUOTE '"');
EOF

echo " ======= CSV, with 1/3 quotes; load times"

for _ in $(seq 2 ${ITER}); do
${PG} <<'EOF'
\timing
truncate table t;
\copy t from /run/user/1000/t_quote.csv (format csv)
EOF
done

rm /run/user/1000/t_quote.csv

echo " ======= Drop table t"

${PG} <<EOF
DROP TABLE IF EXISTS t;
EOF

