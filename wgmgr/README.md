# wgmgr

A simple `wireguard` VPN server (NAT-based) manager.

## Usage

Before running this script, change the variable values at the beginning of the scripts and `client_conf_template` to suit your needs.

```
# init server
wgmgr.sh server init

# add client. this will add the client to server,
# and then display the client configuration
wgmgr.sh client add <name> <ip>

# delete client
wgmgr.sh client delete <name>
```

## TODO

- [ ] auto-allocate available ip address when adding client
- [ ] support passing variables from command line flags
- [ ] support route-based way
- [ ] display qrcode of client configuration
- [ ] support sending email to user
