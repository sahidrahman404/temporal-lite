#!/bin/bash
set -e

# Restore the database if it does not already exist.
if [ -f /data/temporal_data ]; then
	echo "Database already exists, skipping restore"
else
	echo "No database found, restoring from replica if exists"
	litestream restore -if-replica-exists -o /data/temporal_data "${REPLICA_URL}"
fi

setup.sh

# Run litestream with your app as the subprocess.
exec litestream replicate -exec "temporal-server --env development-sqlite-file --allow-no-auth start"
