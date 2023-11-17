# vm

NOTE: currently WIP, limited features & barely usable.

A primitive `qemu` / `kvm` virtual machine manager written in pure bash.

Support defining VMs by a `Vagrantfile`-like file called `vmfile`, see [examples](./examples).

No `libvirt`, no `ruby` & `vagrant`.

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
make install
sudo vmnet br0 192.168.64.1
cd examples/multiple-vms
# create & run all the VMs
vm up
# connect the serial console of one of the VMs
vm console node1
```

## TODO

- [ ] clean up messy code
- [ ] manage VMs without `vmfile` after creation
- [ ] add usage
- [ ] support more cloud images
- [ ] support passing / customizing more `qemu` options
- [ ] test on more Linux distributions & `qemu` versions
- [ ] persistent network configurations
- [ ] leverage `systemd-networkd` & `systemd-resolved`
