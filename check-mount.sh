#!/bin/bash

set -euo pipefail

mount_path=
namespace=
pod_name=

check_mount_rook_shared_fs() {
    if df "$mount_path" | grep -q ":6789" ; then
        return 0
    fi
    error "Mount $mount_path failed"
    return 1
}

delete_pod() {
    ( set -x; kubectl -n "$namespace" delete pod --grace-period=0 --force "$pod_name" )
}

validate() {
    if [ -z "$mount_path" ]; then
        error "required flag: -m mount"
        usage;
    fi
    if [ -z "$namespace" ]; then
        error "required flag: -n namespace"
        usage;
    fi
    if [ -z "$pod_name" ]; then
        error "required flag: -p pod"
        usage;
    fi
}

main() {
    flags $@
    validate

    if check_mount_rook_shared_fs ; then exit 0; fi

    sleep 5 # prevent a tight loop as there is no CrashLoopBackoff when deleting pods
    delete_pod
    exit 1
}

usage() {
    bail "usage: check-mount [[[-m mount] [-p pod] [-n namespace]] | [-h]]"
}

error() {
    echo "$1" 1>&2
}

bail() {
    error "$1"
    exit 1
}

flags() {
    while getopts ":hm:n:p:" opt; do
        case ${opt} in
            m )
                mount_path="$OPTARG"
                ;;
            n )
                namespace="$OPTARG"
                ;;
            p )
                pod_name="$OPTARG"
                ;;
            h )
                usage
                ;;
            \? )
                error "invalid option: -$OPTARG"
                usage
                ;;
            : )
                error "invalid option: -$OPTARG requires an argument"
                usage
                ;;
        esac
    done
    shift $((OPTIND -1))
}

main $@
