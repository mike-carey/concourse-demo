#!/bin/bash

PERMISSIONS=${PERMISSIONS:-644}

filename=$1
shift

echo "$@" > output/$filename

