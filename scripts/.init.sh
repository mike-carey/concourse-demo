#!/usr/bin/env bash

_LOGFILE="$LOGFILE"

source bash-logger.sh

export LOGFILE="$_LOGFILE"

error() {
    ERROR "$@"
    exit ${ERR_CODE:-255}
}

# .init.sh
