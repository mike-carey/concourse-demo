#!/usr/bin/env bash

set -e

source .init.sh

declare DESTINATION

while getopts 'v' param; do
    case $param in
        v ) # Verbose
            export LOGFILE=/dev/stdout
            ;;
        ? ) echo "Unknown option: $OPTARG" 1>&2
            exit 2
            ;;
    esac
done

shift $(($OPTIND - 1))
DESTINATION="$1"

# Validate
if [ -z "$DESTINATION" ]; then
    echo "Missing required argument :destination" 1>&2
    exit 2
fi

INFO "Generating keys in $DESTINATION"
mkdir -p "$DESTINATION"/web "$DESTINATION"/worker

if [ ! -f "$DESTINATION"/web/tsa_host_key ]; then
    INFO "Generating key: /web/tsa_host_key"
    ssh-keygen -t rsa -f "$DESTINATION"/web/tsa_host_key -N ''
    cp "$DESTINATION"/web/tsa_host_key.pub "$DESTINATION"/worker
fi

if [ ! -f "$DESTINATION"/web/session_signing_key ]; then
    INFO "Generating key: /web/session_signing_key"
    ssh-keygen -t rsa -f "$DESTINATION"/web/session_signing_key -N ''
fi

if [ ! -f "$DESTINATION"/worker/worker_key ]; then
    INFO "Generating key: /worker/worker_key"
    ssh-keygen -t rsa -f "$DESTINATION"/worker/worker_key -N ''
    cp "$DESTINATION"/worker/worker_key.pub "$DESTINATION"/web/authorized_worker_keys
fi

# keygen.sh
