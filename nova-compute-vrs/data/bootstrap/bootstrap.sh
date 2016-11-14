#!/usr/bin/env bash

bash /bootstrap/bootstrap-nova-compute-base.sh &


read VSC_IP _ < <(getent hosts $VSC_HOSTNAME)
export NUAGE_ACTIVE_CONTROLLER=$VSC_IP

fix_configs "/etc/default/"
re_write_file "/compute/neutron/neutron.conf" "/etc/neutron/"
re_write_file "/compute/neutron/openvswitch_agent.ini" "/etc/neutron/plugins/ml2/"

sleep 3

/etc/init.d/nuage-openvswitch-switch start &
service openvswitch-switch start &
/usr/share/openvswitch/scripts/nuage-metadata-agent.init start &

sleep 1d