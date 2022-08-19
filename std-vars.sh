#!/bin/bash

apt update ; apt install -y ipcalc

interface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)')
link=$(ip -4 -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr}; done)
ip=$(echo ${link} | cut -d '/' -f1)
netmask=$(ipcalc ${link} | grep Netmask | awk '{ print $2 }')
gateway=$(ip route show default | awk '/default/ { print $3 }')
debconfgateway=$gateway
dns=$(grep nameserver /etc/resolv.conf | grep -v "\#" | head -1 | awk '{ print $2 }')
mirror="deb.debian.org"
password=$(cat /tmp/password)
earlycheck="exit 0"
type="string"

if [ "$dns" == "127.0.0.53" ]; 
then
dns=$(grep -w "DNS" /etc/systemd/resolved.conf | grep -v "\#" | cut -d '=' -f2 | awk '{ print $1 }')
fi

if [ "$gateway" == "10.255.255.1" ]; 
then
mirror="212.27.32.66"
earlycheck="sh -c 'ip link set dev $interface up ; ip addr add $link dev $interface ; ip route add $gateway dev $interface; ip route add default via $gateway dev $interface; mv /sbin/ip /sbin/ip2 ; echo exit 0 > /sbin/ip'"
type=""
debconfgateway="none"
fi

grep -q "/boot" /boot/grub/grub.cfg
if [ $? -eq 1 ];
then
bootpart="/"
else
bootpart="/boot/"
fi
