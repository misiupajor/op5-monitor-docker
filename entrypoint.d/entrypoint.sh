#!/bin/bash
#set -eu pipefail
#set -x

function trigger_hooks() {
    echo "Triggering ${1} hooks"
    /usr/libexec/entrypoint.d/hooks.py $1
}

# trigger prestart hooks defined in hooks.json
trigger_hooks prestart

# import backup file
if [ ! -z "$IMPORT_BACKUP" ]; then
	file="/usr/libexec/entrypoint.d/backups/${IMPORT_BACKUP}"
    if [ ! -e "$file" ]; then
        echo -e "Error importing backup. Backup file ${file} does not exist."
    else
        echo -e "Backup file found. Importing: ${file} ..."
		op5-restore -n -b ${file}
		# remove all peer and poller nodes
		for node in `mon node list --type=peer,poller`; do mon node remove "$node"; done;
		mon stop
    fi
fi
# import license key
if [ ! -z "$LICENSE_KEY" ]; then
	file="/usr/libexec/entrypoint.d/licenses/${LICENSE_KEY}"
	if [ ! -e "$file" ]; then
        echo -e "Error importing license. License file ${file} does not exist."
	else
		if [[ "$file" =~ \.lic$ ]]; then
			echo -e "License file found. Importing license file: ${file} ..."
			mv $file /etc/op5license/op5license.lic
			chown apache:apache /etc/op5license/op5license.lic
			chmod 664 /etc/op5license/op5license.lic
		else
			echo -e "Unable to import license file. License file extension must be .lic"
		fi
	fi
fi

# set default password to 'monitor'
echo 'root:monitor' | chpasswd

# start OP5 related services
services=("sshd" "mysqld" "merlind" "naemon" "httpd" "nrpe" "processor" "collector" "rrdcached" "npcd" "synergy" "smsd" "postgresql" "op5config" "syslog-ng" "crond", "postfix")
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
