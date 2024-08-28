#/bin/bash

set -e

now=$(date +%s)

echo "creating database backup into tmp/"
mkdir -p tmp/
cp -a db/remoteperljobs.sqlite3 tmp/remoteperljobs.sqlite3.$now.sqlite3
sqlite3 db/remoteperljobs.sqlite3 ".dump 'jobs'" > tmp/data.$now.sql

rm -f db/remoteperljobs.sqlite3

echo "creating database and applying patches"
bash bin/create_database.bash
bash bin/apply_database_patches.bash

echo "restoring database backup"
sqlite3 db/remoteperljobs.sqlite3 < tmp/data.$now.sql
