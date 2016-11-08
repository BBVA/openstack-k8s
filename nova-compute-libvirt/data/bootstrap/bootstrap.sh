#!/usr/bin/env bash



mkdir /var/run/dbus/
mkdir /usr/local/lib/python2.7/dist-packages/instances
mkdir -p /var/lib/nova/instances
chmod o+x /var/lib/nova/instances
chown root:kvm /dev/kvm
chmod 666 /dev/kvm
sleep 4
dbus-daemon --config-file=/etc/dbus-1/system.conf &
libvirtd &
