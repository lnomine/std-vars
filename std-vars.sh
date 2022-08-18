#!/bin/bash

apt update ; apt install -y ipcalc

link=$(ip -4 -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr}; done)
ip=$(echo ${link} | cut -d '/' -f1)
netmask=$(ipcalc ${link} | grep Netmask | awk '{ print $2 }')
gateway=$(ip route show default | awk '/default/ { print $3 }')
dns=$(grep nameserver /etc/resolv.conf | grep -v "\#" | head -1 | awk '{ print $2 }')
password=$(cat /tmp/password)

grep -q "/boot" /boot/grub/grub.cfg
if [ $? -eq 1 ];
then
bootpart="/"
else
bootpart="/boot/"
fi
