#!/bin/bash

set -x

filename=$1
shift

echo "$@" > output/$filename
