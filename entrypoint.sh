#!/bin/bash
set -eu pipefail

function start_hook() {
	if [ -e /root/entrypoint.d/hooks/start ]
	then
		for i in `cat /root/entrypoint.d/hooks/start`
		do
			$i
		done
	fi
}

function stop_hook() {
    if [ -e /root/entrypoint.d/hooks/stop ]
    then
        for i in `cat /root/entrypoint.d/hooks/stop`
        do
            $i
        done
    fi
}

# execute shutdown hooks when gracefully shutdown
trap stop_hook SIGTERM
trap stop_hook SIGINT

# start OP5 related services
services=("sshd" "mysqld" "merlind" "naemon" "httpd" "nrpe" "processor" "collector" "rrdcached" "synergy" "smsd" "postgresql")
for i in "${services[@]}"
do
    service $i start
done

exec "$@"
sleep infinity
