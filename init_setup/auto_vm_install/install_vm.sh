#! /bin/bash 
#
# Copyright(c) 2017 All rights reserved by Yongjae Choi. 
# 
# File Name : install_vm.sh
# Purpose : 
# Creation Date : 2017-01-03
# Last Modified : 2017-01-24 02:50:22
# Created By : Yongjae Choi <bestjae@naver.com>
# 
#        --location=/var/lib/libvirt/boot/ubuntu-16.04.1-desktop-amd64.iso \
#

apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils -y
apt-get install virt-manager -y



sudo virt-install \
        --virt-type=kvm  \
        --name ubuntu \
        --ram 8200 \
        --vcpus=4,maxvcpus=4 \
        --os-type linux \
        --connect=qemu:///system \
        --os-variant=ubuntutrusty \
        --hvm \
        --noautoconsole \
		--location 'http://archive.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/' \
        --network network=default,model=virtio \
        --graphics none \
        --disk path=/dev/nvme0n1,bus=virtio \
        --initrd-inject=./preseed.cfg \
        --extra-args "console=ttyS0,115200 auto=true interface=auto language=en country=kr"
