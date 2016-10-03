#!/usr/bin/env bash


source functions.sh
get_environment

# Get my IPv4 address (including netmask)
read _ MY_IP _  < <(ip addr show eth0 | grep "inet ")

# Get the local GW
read _ _ MY_GW _ < <(ip route list match 0/0)

# Get my DNS server. When using K8S this is set at runtime in "/etc/resolv.conf"
read _ MY_DNS  < <(cat /etc/resolv.conf | grep nameserver)

MY_HOSTNAME=`hostname`

export MY_IP
export MY_GW
export MY_DNS
export MY_HOSTNAME


guestmount -a /image/image.qcow2 -m /dev/sda1  /mnt
# Fix the VSC config files
fix_configs /bootstrap/*.cfg
cp -f /bootstrap/*.cfg /mnt
### (!!!) The "bof.cfg" _must_ be world-wide executable but "config.cfg" _not_
chmod 0755 /mnt/bof.cfg
chmod 0644 /mnt/config.cfg

guestunmount /mnt

/usr/local/bin/startvm -smbios type=1,product=TIMOS -nographic