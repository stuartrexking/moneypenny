#!/usr/bin/env bash

set -e

apt-get install -y lxc

#These need to exist
declare -a users=(stuartrexking leecampbell)

for user in "${users[@]}"
do

SUBUID=`grep $user /etc/subuid | awk -F: '{ print $2}'`
SUBGID=`grep $user /etc/subgid | awk -F: '{ print $2}'`

mkdir -p /home/$user/.config/lxc
echo "lxc.id_map = u 0 $SUBUID 65536" > /home/$user/.config/lxc/default.conf
echo "lxc.id_map = g 0 $SUBGID 65536" >> /home/$user/.config/lxc/default.conf
echo "lxc.network.type = veth" >> /home/$user/.config/lxc/default.conf
echo "lxc.network.link = lxcbr0" >> /home/$user/.config/lxc/default.conf

chmod -R 0744 /home/$user/.config
chown -R $user:$user /home/$user

echo "$user veth lxcbr0 10" | tee -a /etc/lxc/lxc-usernet

done
