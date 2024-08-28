#!/bin/bash

set -e

DB_FILEPATH='db/remoteperljobs.sqlite3'
if [ -f $DB_FILEPATH ]; then
	echo "$DB_FILEPATH exists"
	exit 1
fi

touch $DB_FILEPATH
