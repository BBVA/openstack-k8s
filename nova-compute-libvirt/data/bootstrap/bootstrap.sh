#!/usr/bin/env bash

cat > /etc/libvirt/libvirt.conf <<EOF
listen_tls = 0
listen_tcp = 1
auth_tcp="none"
tcp_port = "16509"
listen_addr = "0.0.0.0"
EOF

mkdir /var/run/dbus/
mkdir /usr/local/lib/python2.7/dist-packages/instances
mkdir -p /var/lib/nova/instances
chmod o+x /var/lib/nova/instances
chown root:kvm /dev/kvm
chmod 666 /dev/kvm
sleep 4
dbus-daemon --config-file=/etc/dbus-1/system.conf &
libvirtd -d -l -f /etc/libvirt/libvirt.conf &
sleep 1d