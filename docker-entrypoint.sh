#!/bin/bash
set -e
if [ "$1" = 'mon' ]; then
    "$@"
else
    # As argument is not related to OP5
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi

# start OP5 related services
services=("sshd" "mysqld" "merlind" "naemon" "httpd" "nrpe" "processor" "collector" "rrdcached" "synergy" "smsd" "postgresql")
for i in "${services[@]}"
do
    service $i start
done
sleep infinity
