#!/usr/bin/env bash
# shellcheck disable=SC2312,SC2015
set -o pipefail

db=/tmp/etcd
lock=/tmp/etcd.lock

lock() {
    exec 3<>"${lock}"
    flock -n 3
}

shared_lock() {
    exec 3<>"${lock}"
    flock -s -n 3
}

unlock() {
    flock -u 3
}

put() {
    lock
    echo PUT "${1}" "${2}" >>"$db"
    unlock
}

del() {
    lock
    # TODO: avoid duplicated deletions
    # TODO: don't do anything when key doesn't exist
    echo DEL "${1}" >>"${db}"
    unlock
}

_output() {
    # echo >&11 "$@"
    echo "$@"
}

match() {
    if ((prefix)); then
        [[ "${1}" == "${2}"* ]]
        return
    fi
    [[ "${1}" == "${2}" ]]
}

_scan_db() {
    local key=${1:-}
    local start=${start:-1}
    local end=${end:-0}

    local watch=${watch:-0}
    local get=${get:-0}

    local k v rev
    # shellcheck disable=SC2312
    while read -r action k v; do
        rev=$((start++))

        match "${k}" "${key}" || continue

        values[${k}]=${v}
        mod_rev[${k}]=${rev}
        ((seen[${k}]++)) || create_rev[${k}]=${rev}

        [[ ${action} == DEL ]] && unset "create_rev[${k}]" "values[${k}]" "seen[${k}]"

        ((watch)) || continue

        _output "rev=${rev} create=$((create_rev[${k}])) mod=$((mod_rev[${k}])) version=$((seen[${k}]))"
        _output "${action}"
        _output "${k}"
        _output "${values[${k}]}"
    done < <(
        ((watch)) && tail -n +"${start}" -f "${db}" || head -n "${end}" "${db}"
    )

    ((get)) || return

    _output "count=${#values[@]}"
    for k in "${!values[@]}"; do
        _output "create=$((create_rev[${k}])) mod=$((mod_rev[${k}])) version=$((seen[${k}]))"
        _output "${k}"
        _output "${values[${k}]}"
    done
}

get() {
    local key=$1
    local -A seen create_rev mod_rev values
    local latest_rev
    latest_rev=$(wc -l <"${db}")
    ((rev)) || rev=${latest_rev}

    _output "rev=${latest_rev}"
    get=1 end="${rev}" _scan_db "${key}"

}

watch() {
    local key=$1
    local -A seen create_rev mod_rev values
    local latest_rev
    latest_rev=$(wc -l <"${db}")
    ((rev)) || rev=$((latest_rev + 1))

    _output "rev=${latest_rev}"

    end=$((rev - 1)) _scan_db "${key}"
    watch=1 start="${rev}" _scan_db "${key}"
}

main() {
    trap '[[ -z "$(jobs -p)" ]] || kill $(jobs -p)' EXIT

    local fifo
    fifo=$(mktemp --dry-run)
    mkfifo "${fifo}"
    exec 12<>"${fifo}"
    rm -f "${fifo}"

    exec 1>&11

    cat <&10 >&12 &
    read_pid=$!

    local cmd
    read -u 12 -r cmd
    local rev=0 prefix=0
    # NOTE: this is extremely unsafe, just for convenience
    eval "${cmd}" &
    write_pid=$!

    wait -n $read_pid $write_pid
}

# stop at here when being sourced to avoid actual execution
# https://stackoverflow.com/a/2684300
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return

main "$@"
