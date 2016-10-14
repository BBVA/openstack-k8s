#!/usr/bin/env bash

#############################
# Include scripts
#############################
source /bootstrap/configuration.sh
source /bootstrap/environment.sh
source /bootstrap/semaphore-dependencies.sh

check_dependency "neutron"

#############################
# variables and environment
#############################
get_environment
SQL_SCRIPT=/bootstrap/neutron.sql

############################
# CONFIGURE NEUTRON
############################
# llamada a la funcion del configuration.sh
re_write_file "/controller/neutron/neutron.conf" "/etc/neutron/"
re_write_file "/controller/neutron/ml2_conf.ini" "/etc/neutron/plugins/ml2/"
re_write_file "/controller/neutron/openvswitch_agent.ini" "/etc/neutron/plugins/ml2/"
re_write_file "/controller/neutron/l3_agent.ini" "/etc/neutron/"
re_write_file "/controller/neutron/dhcp_agent.ini" "/etc/neutron/"
re_write_file "/controller/neutron/metadata_agent.ini" "/etc/neutron/"
fix_configs $SQL_SCRIPT
sleep 2
MI_IP=`ip a | grep 10.4 | awk '{print $2}' | cut -d"/" -f1`
echo "El valor de MY_IP es: $MI_IP"
sed -i "s%^local_ip.*=.*%local_ip = $MI_IP%" /etc/neutron/plugins/ml2/openvswitch_agent.ini
sleep 2
############################
# DATABASE BOOTSTRAP
############################

if ! does_db_exist neutron; then

    # create database
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT

    # configure the service and endpoint url
    export OS_USERNAME=$ADMIN_USER_NAME
    export OS_PASSWORD=$ADMIN_PASSWORD
    export OS_TENANT_NAME=$ADMIN_TENANT_NAME
    export OS_AUTH_URL=$OS_URL

    openstack service create  --name neutron --description "Openstack Networking" network
    openstack user create --domain default --password $NEUTRON_PASSWORD $NEUTRON_USERNAME
    openstack role add --project services --user $NEUTRON_USERNAME admin
    openstack endpoint create --region $REGION network public https://$NEUTRON_OFUSCADO
    openstack endpoint create --region $REGION network internal http://$NEUTRON_HOSTNAME:9696
    openstack endpoint create --region $REGION network admin http://$NEUTRON_HOSTNAME:9696

    # sync the database
    neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head


fi

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

service openvswitch-switch start &
sleep 5
ovs-vsctl add-br br-ex
neutron-server --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini &
neutron-openvswitch-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/openvswitch_agent.ini &
neutron-dhcp-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/dhcp_agent.ini &
neutron-metadata-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/metadata_agent.ini &
neutron-l3-agent --config-file /etc/neutron/l3_agent.ini --config-file /etc/neutron/neutron.conf
