#!/usr/bin/env bash

# modify the following variable values
server_addr=192.168.64.1/24
server_pub_endpoint=public_ip_or_domain
output_iface=eth0
wg_iface=wg0
port=51820

conf=/etc/wireguard/${wg_iface}.conf
test=${test:-0}
((test)) && conf=/tmp/${wg_iface}.conf
service=wg-quick@${wg_iface}.service
prefix=${server_addr%.*}

client_conf_template() {
    cat <<EOF
[Interface]
Address = ${addr}
PrivateKey = ${key}
# TODO: you can put more custom configurations below
# DNS = ...
# PostUp = ...

[Peer]
PersistentKeepalive = 25
PublicKey = ${server_pubkey}
PresharedKey = ${psk}
server_pub_endpoint = ${server_pub_endpoint}:${port}
AllowedIPs = ${prefix}.1/32
# TODO: you can put more AllowedIPs below
# AllowedIPs = ...
EOF
}

err() {
    echo >&2 "$@"
    return 1
}

die() {
    echo >&2 "$@"
    exit 1
}

check_deps() {
    command -v wg-quick &>/dev/null || die "command 'wg-quick' not found, please install 'wireguard-tools' first."
}

restart() {
    ((test)) || systemctl restart "${service}"
}

keypair() {
    key=$(wg genkey)
    pubkey=$(wg pubkey <<<"${key}")
}

psk() {
    psk=$(wg genpsk)
}

get_server_pubkey() {
    local key
    key=$(sed -n '/^\[Interface\]$/,/^$/ { /PrivateKey/ s/PrivateKey = // p }' "${conf}")
    wg pubkey <<<"${key}"
}

server_init() {
    local key pubkey
    keypair

    cat <<EOF >"${conf}"
[Interface]
Address = ${server_addr}
ListenPort = ${port}
PrivateKey = ${key}
# substitute eth0 in the following lines to match the Internet-facing interface
# if the server is behind a router and receives traffic via NAT, these iptables rules are not needed
PostUp = iptables -A FORWARD -i %i -j ACCEPT
PostUp = iptables -A FORWARD -o %i -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o ${output_iface} -j MQSQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -D FORWARD -o %i -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o ${output_iface} -j MQSQUERADE

EOF

    restart
}

check_name() {
    [[ ${1} =~ [A-Za-z0-9@_\.\-]+ ]] ||
        die "client name should contain only alphanum and [@_.-]"
}

escape_name() {
    # shellcheck disable=SC2001
    sed 's/[.-]/\\&/g' <<<"${1}"
}

client_add() {
    local name=${1}
    local addr=${2}
    check_name "${name}"

    local server_pubkey
    server_pubkey=$(get_server_pubkey)

    local key pubkey psk
    keypair
    psk

    # TODO: dest config
    cat <<EOF >>"${conf}"
[Peer] # ${name}
PublicKey = ${pubkey}
PresharedKey = ${psk}
AllowedIPs = ${addr}/32

EOF

    restart

    client_conf_template
}

client_delete() {
    local name=${1}
    local pattern
    pattern=$(escape_name "${name}")
    sed -i "/^\[Peer\] # ${pattern}$/,/^$/d" "${conf}"
    restart
}

usage() {
    local cmd
    cmd=$(basename "$0")
    cat >&2 <<EOF
Usage:
# init server
${cmd} server init

# add client. this will add the client to server,
# and then display the client configuration
${cmd} client add <name> <ip>

# delete client
${cmd} client delete <name>
EOF
}

main() {
    check_deps

    action=${1}_${2}
    shift 2
    case ${action} in
    server_init | client_add | client_delete)
        "${action}" "$@"
        ;;
    *) usage ;;
    esac
}

main "$@"
