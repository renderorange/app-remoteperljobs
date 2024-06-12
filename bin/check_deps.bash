#!/bin/bash

EXIT_CODE=0
for dep in git cpanm sqlite3; do
	echo -n "$dep - "
	if command -v $dep >/dev/null 2>&1; then
		echo "found"
	else
		EXIT_CODE=1
		echo "not found"
	fi
done
exit $EXIT_CODE
