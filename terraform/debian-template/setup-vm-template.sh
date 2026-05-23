#!/bin/bash
# to run as root

IMAGEURL=https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2

wget $IMAGEURL
qm create 9000 --name debian-13-template --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0
qm importdisk 9000 debian-13-genericcloud-amd64.qcow2 local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000