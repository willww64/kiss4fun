# ragged-flannel

This is a ragged version of flannel (`vxlan` backend). It's also a demo of how to use [duck-etcd](../duck-etcd).

Although it's "ragged", but it does implement the basic `list & wach`. It will maintain/update the flannel `rules` when node is added or deleted.

## Steps

Please install `make` and `vagrant` first.

### Bring them up

There are 4 VMs defined in the `Vagrantfile`.
The node name and corresponding IP addresses are as follows:

| node name | host ip       | pod subnet    |
| --------- | ------------- | ------------- |
| etcd      | 192.168.56.60 |               |
| node1     | 192.168.56.61 | 10.244.1.0/24 |
| node2     | 192.168.56.62 | 10.244.2.0/24 |
| node3     | 192.168.56.63 | 10.244.3.0/24 |


```bash
git clone https://github.com/willww64/kiss4fun.git
cd kiss4fun/ragged-flannel
make
```

### Test the result

`vagrant ssh` to any node, execute

```bash
for i in {1..3} ; do
    sudo ip netns exec ns1 ping -c1 -w 1 10.244.${i}.2 &>/dev/null &&
        echo 10.244.${i}.2 succeeded ||
        echo 10.244.${i}.2 failed
done
```
