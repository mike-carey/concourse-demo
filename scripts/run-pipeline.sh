#!/usr/bin/env bash

set -e

source .init.sh

declare SOURCE=./pipelines
declare TARGET=lite
declare PIPELINE

while getopts 'vs:t:' param; do
    case $param in
        s ) # Source
            SOURCE="$OPTARG"
            ;;
        t ) TARGET="$OPTARG"
            ;;
        v ) # Verbose
            export LOGFILE=/dev/stdout
            ;;
        ? ) echo "Unknown option: $OPTARG" 1>&2
            exit 2
            ;;
    esac
done

shift $(($OPTIND - 1))
PIPELINE="$1"

if [ -z "$SOURCE" ]; then
    echo "Missing required argument :pipeline" 1>&2
    exit 2
fi

if [ -e "$SOURCE"/*_"$PIPELINE" ]; then
    echo "Could not find pipeline under $SOURCE/*_$PIPELINE" 1>&2
    exit 3
fi

DIRECTORY=$(echo "$SOURCE"/*_"$PIPELINE")
INFO "Directory for $PIPELINE is $DIRECTORY"

INFO "Running pipeline: $PIPELINE"
fly -t "$TARGET" set-pipeline -n -p "$PIPELINE" -c "$DIRECTORY"/concourse.yml
fly -t "$TARGET" unpause-pipeline -p "$PIPELINE"

# run-pipeline.sh
