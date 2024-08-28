#/bin/bash

DB_FILEPATH='db/remoteperljobs.sqlite3'

function apply_patch () {
	patch_full_path=$1
	patch=$(basename $patch_full_path)

	exists=$(sqlite3 $DB_FILEPATH "select count(*) from db_patch_history where patch_name = '$patch'" 2> /dev/null)

	if [ -z "$exists" ] || [ "$exists" -eq "0" ]; then
		echo "applying $patch_full_path"
		sqlite3 $DB_FILEPATH < $patch_full_path
		sqlite3 $DB_FILEPATH "insert into db_patch_history (patch_name, applied_on) values ('$patch', $(date +%s))"
	fi

	return
}

# apply schema structure first
for patch in $(ls -d -1 db/schema/*.sqlite3 2> /dev/null); do
	apply_patch $patch
done

# then apply data updates
for patch in $(ls -d -1 db/data/*.sqlite3 2> /dev/null); do
	apply_patch $patch
done
