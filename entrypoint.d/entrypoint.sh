#!/bin/bash
#set -eu pipefail
set -x

function trigger_hooks() {
    echo "Triggering ${1} hooks"
    /usr/libexec/entrypoint.d/hooks.py $1
}

# trigger prestart hooks defined in hooks.json
trigger_hooks prestart

# import backup file
if [ ! -z "$IMPORT_BACKUP" ]; then
	file="/usr/libexec/entrypoint.d/backups/${IMPORT_BACKUP}"
    if [ ! -f "$file" ]; then
        echo -e "Error. Failed to import backup. File is missing: ${file}. Skipping...\n"
    else
        echo -e "Backup file found. Importing: ${file} ...\n"
		op5-restore -n -b ${file}
		# remove all peer and poller nodes
		for node in `mon node list --type=peer,poller`; do mon node remove "$node"; done;
		mon stop
    fi
fi

# set default password to 'monitor'
echo 'root:monitor' | chpasswd

# start OP5 related services
services=("sshd" "mysqld" "merlind" "naemon" "httpd" "nrpe" "processor" "collector" "rrdcached" "synergy" "smsd" "postgresql", "op5config")
for i in "${services[@]}"
do
    service $i restart
done


exec "$@"
# trigger poststop hooks defined in hooks.json
trap 'kill ${!}; trigger_hooks poststop' SIGTERM

# trigger poststart defined in hooks.json
trigger_hooks poststart

# wait indefinitely
    while true
    do
      tail -f /dev/null & wait ${!}
    done
