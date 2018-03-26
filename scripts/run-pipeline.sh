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
    ERR_CODE=2 error "Missing required argument :pipeline"
fi

if [ ! -e "$SOURCE"/*_"$PIPELINE" ]; then
    ERR_CODE=3 error "Could not find pipeline under $SOURCE/*_$PIPELINE"
fi

DIRECTORY=$(echo "$SOURCE"/*_"$PIPELINE")
INFO "Directory for $PIPELINE is $DIRECTORY"

LOAD_VARS=
if [ -f "$DIRECTORY"/params.yml ]; then
    # Require the .params.yml
    if [ ! -f "$DIRECTORY"/.params.yml ]; then
        ERR_CODE=4 error "Missing custom params file: $DIRECTORY/.params.yml"
    fi

    LOAD_VARS="-l \"$DIRECTORY\"/.params.yml"
fi

RUN_CMD="fly -t \"$TARGET\" set-pipeline -n -p \"$PIPELINE\" -c \"$DIRECTORY\"/pipeline.yml $LOAD_VARS"

INFO "Running pipeline: $PIPELINE"
INFO "Command: $RUN_CMD"
eval $RUN_CMD
fly -t "$TARGET" unpause-pipeline -p "$PIPELINE"

# run-pipeline.sh
