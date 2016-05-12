#!/bin/bash

set -e

username="ubuntu"
user_home_dir="/home/${username}"

# Updating and Upgrading dependencies
sudo apt-get update -y -qq > /dev/null
sudo apt-get upgrade -y -qq > /dev/null

# Install necessary libraries for guest additions and Vagrant NFS Share
sudo apt-get -y -q install linux-headers-$(uname -r) build-essential libyaml-dev dkms libffi-dev libssl-dev nfs-common xserver-xorg xserver-xorg-core curl wget virtualbox-guest-utils virtualbox-guest-x11 virtualbox-guest-dkms

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin "$username"
usermod -a -G admin root

cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Installing vagrant keys
mkdir "${user_home_dir}/.ssh"
chmod 700 "${user_home_dir}/.ssh"
cd "${user_home_dir}/.ssh"
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 "${user_home_dir}/.ssh/authorized_keys"
chown -R "$username" "${user_home_dir}/.ssh"

mkdir /tmp/virtualbox
VERSION=$(cat ${user_home_dir}/.vbox_version)
mount -o loop ${user_home_dir}/VBoxGuestAdditions_$VERSION.iso /tmp/virtualbox
sh /tmp/virtualbox/VBoxLinuxAdditions.run --nox11 | true
umount /tmp/virtualbox
rmdir /tmp/virtualbox
rm ${user_home_dir}/*.iso
