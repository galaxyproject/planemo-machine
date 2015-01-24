#!/bin/bash -eux

# delete linux source
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge

# delete obsolete networking
apt-get -y purge ppp pppconfig pppoeconf

# delete oddities
apt-get -y purge popularity-contest

apt-get -y autoremove
apt-get -y clean
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
