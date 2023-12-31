# duck-etcd (WIP)

> If it writes like an etcd and it reads like an etcd, then it must be an etcd.

A toy KV store written in pure bash.

Features implemented:

- basic ops (put, del, get, watch)
- prefix support
- full revision support (including create & mod revision)
- `etcd` & `etcdctl` command

Basic ideas behind the scene:

- use a single text file to store data
- use line numbers as revisions
- use `socat` as communication channel (some damn edge cases need to be taken care of)
- server forks sub-processes to handle concurrent requests
- use `flock` to protect concurrent writes

## Requirements

- linux (cause I use `flock`, which is a command from `util-linux`)
- bash (version 5 or higher)
- socat

Tested on `Arch Linux` with `bash 5`, might not work with other linux distros or older bash versions.

## Usage

Run the server

```
$ etcd
```

Run the client

```
$ etcdctl put a a
$ etcdctl put b b
$ etcdctl put c c
$ etcdctl put b b1
$ etcdctl del c
$ etcdctl get a
$ etcdctl get b
$ etcdctl get b --rev 3
$ etcdctl get c
$ etcdctl get c --rev 3
$ etcdctl get "" --prefix
$ etcdctl watch "" --prefix --rev 3
```
