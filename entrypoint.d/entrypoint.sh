#!/bin/bash
#set -eu pipefail

# import backup file
if [ ! -z "$import_backup" ]; then
	file="/usr/libexec/entrypoint.d/backups/${import_backup}"
    if [ ! -f "$file" ]; then
        echo -e "Error. Failed to import backup. File is missing: ${file}. Skipping...\n"
    else
        echo -e "Backup file found. Importing: ${file} ...\n"
#        op5-restore -n -b ${file}; mon stop
    fi
fi

function trigger_hooks() {
	/usr/libexec/entrypoint.d/hooks.py $1
}

# execute start hooks
trigger_hooks start

# execute shutdown hooks when gracefully shutdown
trap 'trigger_hooks stop' SIGTERM
trap 'trigger_hooks stop' SIGINT

# start OP5 related services
services=("sshd" "mysqld" "merlind" "naemon" "httpd" "nrpe" "processor" "collector" "rrdcached" "synergy" "smsd" "postgresql")
for i in "${services[@]}"
do
    service $i start
done

exec "$@"
sleep infinity
