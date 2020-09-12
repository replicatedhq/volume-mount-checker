#!/bin/bash

set -eo pipefail

bail() {
    echo "$1" 1>&2
    exit 1
}

if [ -z "$MOUNT_PATH" ]; then
    bail "MOUNT_PATH required"
fi
if [ -z "$NAMESPACE" ]; then
    bail "NAMESPACE required"
fi
if [ -z "$POD_NAME" ]; then
    bail "POD_NAME required"
fi

./check-mount.sh -m "$MOUNT_PATH" -n "$NAMESPACE" -p "$POD_NAME"
