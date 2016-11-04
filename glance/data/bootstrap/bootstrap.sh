#!/usr/bin/env bash

#############################
# Include scripts
#############################
source /bootstrap/configuration.sh
source /bootstrap/environment.sh
source /bootstrap/semaphore-dependencies.sh

check_dependency "glance"

#############################
# variables and environment
#############################
get_environment
SQL_SCRIPT=/bootstrap/glance.sql

############################
# CONFIGURE GLANCE
############################
# llamada a la funcion del configuration.sh
re_write_file "/controller/glance/glance-api.conf" "/etc/glance/"
re_write_file "/controller/glance/glance-registry.conf" "/etc/glance/"
fix_configs $SQL_SCRIPT

############################
# DATABASE BOOTSTRAP
############################


if ! does_db_exist glance; then

    # create database
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT

    # sync the database
    glance-manage db_sync

    # configure the service and endpoint url
    export OS_USERNAME=$ADMIN_USER_NAME
    export OS_PASSWORD=$ADMIN_PASSWORD
    export OS_TENANT_NAME=$ADMIN_TENANT_NAME
    export OS_AUTH_URL=$OS_URL

    openstack service create  --name glance --description "Openstack Image Service" image
    openstack endpoint create --region $REGION image public https://$GLANCE_OFUSCADO
    openstack endpoint create --region $REGION image internal http://$GLANCE_HOSTNAME:9292
    openstack endpoint create --region $REGION image admin http://$GLANCE_HOSTNAME:9292
    openstack user create --domain default --password $GLANCE_PASSWORD $GLANCE_USERNAME
    openstack role add --project services --user $GLANCE_USERNAME admin

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

cat ~/openrc


# start glance service
glance-registry &
sleep 5
glance-api