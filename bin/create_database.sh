#!/bin/bash

DB_FILEPATH='db/remoteperljobs.sqlite3'
if [ -f $DB_FILEPATH ]; then
	echo "$DB_FILEPATH exists"
	exit 1
fi

touch $DB_FILEPATH

for patch in $(ls -1 db/schema/); do
	echo "applying $patch"
	sqlite3 db/remoteperljobs.sqlite3 < db/schema/$patch
done
