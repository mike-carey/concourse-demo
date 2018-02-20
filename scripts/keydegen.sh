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

INFO "Destroying keys in $DESTINATION"
rm -rf "$DESTINATION"/web 
rm -rf "$DESTINATION"/worker


# keygen.sh
