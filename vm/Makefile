SHELL := /bin/bash

download-debian12: dir=~/.local/share/vm/cloud-images
download-debian12:
	[[ -d $(dir) ]] || mkdir -p $(dir)
	cd $(dir) && curl -fLO https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2

install:
	sudo install --mode=0755 vm vmnet /usr/local/bin/
