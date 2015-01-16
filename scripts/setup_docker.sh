#!/bin/bash
set -e

# Make Docker box look kind of like Amazon cloud image with
# passwordless sudo for ubuntu user.

adduser --quiet --disabled-password -shell /bin/bash --home /home/ubuntu --gecos "User" ubuntu
# set password
echo "ubuntu:ubuntu" | chpasswd

# Setup sudo to allow no-password sudo for "admin"
# quietly add a user
groupadd -r admin
usermod -a -G admin ubuntu
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers
