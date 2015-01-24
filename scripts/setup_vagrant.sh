#!/bin/bash

set -e

# Updating and Upgrading dependencies
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null

# Install necessary libraries for guest additions and Vagrant NFS Share
sudo apt-get -y -q install linux-headers-$(uname -r) build-essential dkms nfs-common

# Install necessary dependencies
sudo apt-get -y -q install curl wget

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Installing vagrant keys
mkdir ~vagrant/.ssh
chmod 700 ~vagrant/.ssh
cd ~vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 ~vagrant/.ssh/authorized_keys
chown -R vagrant ~vagrant/.ssh

mkdir /tmp/virtualbox
VERSION=$(cat /home/vagrant/.vbox_version)
mount -o loop /home/vagrant/VBoxGuestAdditions_$VERSION.iso /tmp/virtualbox
# Following line will return a non-zero exit code because
# X11 extensions cannot be installed. This is fine - so just
# keep going.
sh /tmp/virtualbox/VBoxLinuxAdditions.run | true
umount /tmp/virtualbox
rmdir /tmp/virtualbox
rm /home/vagrant/*.iso
