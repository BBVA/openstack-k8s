#!/usr/bin/env bash

#############################
# Execute script nova-compute-base

bash /bootstrap/bootstrap-nova-compute-base.sh &
#############################

#############################
# Include scripts
#############################
source /bootstrap/configuration.sh
source /bootstrap/environment.sh
source /bootstrap/semaphore-dependencies.sh

check_dependency "nova-compute"

#############################
# variables and environment
#############################
get_environment

############################
# CONFIGURE NOVA
############################
# llamada a la funcion del configuration.sh
re_write_file "/compute/neutron/neutron.conf" "/etc/neutron/"
re_write_file "/compute/neutron/openvswitch_agent.ini" "/etc/neutron/plugins/ml2/"

sleep 3
MI_IP=`ip a | grep 10.4 | awk '{print $2}' | cut -d"/" -f1`
echo "El valor de MY_IP es: $MI_IP"
sed -i "s%^local_ip.*=.*%local_ip = $MI_IP%" /etc/neutron/plugins/ml2/openvswitch_agent.ini
# create a admin-openrc.sh file

cat >~/openrc <<EOF
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASSWORD
export OS_AUTH_URL=http://$KEYSTONE_HOSTNAME:35357/v3
export OS_IDENTITY_API_VERSION3=
export OS_IMAGE_API_VERSION=2
export OS_INTERFACE=internal
EOF

service openvswitch-switch start &
sleep 4
ovs-vsctl add-br br-ex
neutron-openvswitch-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/openvswitch_agent.ini &
sleep 1d
