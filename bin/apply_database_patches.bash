#/bin/bash

set -e

DB_FILEPATH='db/remoteperljobs.sqlite3'

for patch in $(ls -1 db/schema/); do
	exists=$(sqlite3 $DB_FILEPATH "select count(*) from db_patch_history where patch_name = '$patch'")
	if [ "$exists" -eq "0" ]; then
		echo "applying $patch"
		sqlite3 $DB_FILEPATH < db/schema/$patch
		sqlite3 $DB_FILEPATH "insert into db_patch_history (patch_name, applied_on) values ('$patch', $(date +%s))"
	fi
done
