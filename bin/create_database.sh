#!/bin/bash

set -e

DB_FILEPATH='db/remoteperljobs.sqlite3'
if [ -f $DB_FILEPATH ]; then
	echo "$DB_FILEPATH exists"
	exit 1
fi

touch $DB_FILEPATH

for patch in $(ls -1 db/schema/); do
	echo "applying $patch"
	sqlite3 $DB_FILEPATH < db/schema/$patch
done

for patch in $(ls -1 db/schema); do
	sqlite3 $DB_FILEPATH "insert into db_patch_history (patch_name, applied_on) values ('$patch', $(date +%s))"
done
