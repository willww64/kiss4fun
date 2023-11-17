# vm

NOTE: currently WIP, limited features & barely usable.

A primitive `qemu` / `kvm` virtual machine manager written in pure bash.

Support defining VMs by a `Vagrantfile`-like file called `vmfile`, see [examples](./examples). No need for `ruby`, `vagrant` or `libvirt`.

Use `cloud-init` to initialize VMs.


## Compatibility

Linux-only, only tested on `CentOS 7` and `ArchLinux`.

## Dependencies

CentOS 7

```bash
yum install -y qemu-kvm make socat genisoimage
```

ArchLinux

```bash
pacman -Syu qemu-base socat cdrtools
```

## Steps

```bash
# download debian 12 cloud image
make download-debian12
make install

# setup bridge network
sudo vmnet br0 192.168.64.1

cd examples/multiple-vms
# create & run all VMs
vm up

# connect the serial console of one of the VMs
# you may need to hit enter if nothing is shown.
vm console node1
# TODO: add ssh example after finishing leveraging systemd-resolved

# poweroff all VMs
vm poweroff
# delete all VMs
vm delete
```

## TODO

- [ ] clean up messy code
- [ ] manage VMs without `vmfile` after creation
- [ ] add usage
- [ ] support more cloud images, and cloud image management (list, delete, download)
- [ ] support passing / customizing more `qemu` options
- [ ] test on more Linux distributions & `qemu` versions
- [ ] persistent network configurations
- [ ] leverage `systemd-networkd` & `systemd-resolved`
