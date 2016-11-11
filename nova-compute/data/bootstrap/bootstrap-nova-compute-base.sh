#!/usr/bin/env bash

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
re_write_file "/compute/nova/nova.conf" "/etc/nova/"

sleep 3
MI_IP=`ip a | grep 10.4 | awk '{print $2}' | cut -d"/" -f1`
echo "El valor de MY_IP es: $MI_IP"
sed -i "s!^my_ip.*=.*!my_ip = $MI_IP!" /etc/nova/nova.conf
sed -i "s!^#metadata_host.*=.*!metadata_host = $MI_IP!" /etc/nova/nova.conf
# create a admin-openrc.sh file

cat >~/openrc <<EOF
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASSWORD
export OS_AUTH_URL=http://$KEYSTONE_HOSTNAME:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export OS_INTERFACE=internal
EOF

nova-compute --config-file=/etc/nova/nova.conf