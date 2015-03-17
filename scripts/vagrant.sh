#!/usr/bin/env bash

useradd -d /home/vagrant -s /bin/bash vagrant 

groupadd admin
usermod -G admin vagrant
echo '%admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
echo 'UseDNS no' >> /etc/ssh/sshd_config
/etc/init.d/sudo restart

mkdir -p /home/vagrant/.ssh/
chmod 700 /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

apt-get update
apt-get -y install linux-headers-$(uname -r) dkms

mkdir /tmp/virtualbox
VERSION=$(cat /home/packer/.vbox_version)
mount -o loop /home/packer/VBoxGuestAdditions_$VERSION.iso /tmp/virtualbox
sh /tmp/virtualbox/VBoxLinuxAdditions.run
umount /tmp/virtualbox
rmdir /tmp/virtualbox
rm /home/vagrant/*.iso

dd if=/dev/zero of=/EMPTY bs=1M
rm /EMPTY
