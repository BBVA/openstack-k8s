#!/usr/bin/env bash

#############################
# Include scripts
#############################
source /bootstrap/configuration.sh
source /bootstrap/environment.sh

#############################
# variables and environment
#############################
get_environment
SQL_SCRIPT=/bootstrap/keystone.sql

############################
# CONFIGURE KEYSTONE
############################
# llamada a la funcion del configuration.sh
re_write_file "/controller/keystone/keystone.conf" "/etc/keystone/"
fix_configs $SQL_SCRIPT

############################
# DATABASE BOOTSTRAP
############################

mkdir /etc/keystone/fernet-keys
echo "xRFeIEUineSD9EnHlraby90RAxIkekN_ZdGNhdZ2u3M=">/etc/keystone/fernet-keys/0
echo "BLy_nPN2ekT0DrfFWOwxW6FpQUuu5FTrGb--cbdcPYo="

if ! does_db_exist keystone; then

    # create database keystone
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT
    # Populate the Identity service database
    keystone-manage db_sync
    # Initialize Fernet keys
    #keystone-manage fernet_setup --keystone-user root --keystone-group root
    mv /etc/keystone/default_catalog.templates /etc/keystone/default_catalog

    # start keystone service and wait
    uwsgi --http 0.0.0.0:35357 --wsgi-file $(which keystone-wsgi-admin) &
    sleep 5

    # Initialize account
    export $OS_TOKEN $OS_URL $OS_IDENTITY_API_VERSION
    openstack service create  --name keystone --description "Openstack Identity" identity
    openstack endpoint create --region $REGION identity public https://$KEYSTONE_OFUSCADO/v3
    openstack endpoint create --region $REGION identity internal http://$KEYSTONE_HOSTNAME:5000/v3
    openstack endpoint create --region $REGION identity admin http://$KEYSTONE_HOSTNAME:35357/v3
    openstack domain create --description "Default Domain" default
    openstack project create --domain default  --description "Admin Project" admin
    openstack project create --domain default  --description "Service Project" services
    openstack user create --domain default --password $ADMIN_PASSWORD admin
    openstack role create admin
    openstack role create user
    openstack role add --project admin --user admin admin

    unset $OS_TOKEN $OS_URL
fi

#############################
# Write openrc to disk
#############################
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

#############################
# reboot services
#############################
pkill uwsgi
sleep 5
uwsgi --http 0.0.0.0:5000 --wsgi-file $(which keystone-wsgi-public) &
sleep 5
uwsgi --http 0.0.0.0:35357 --wsgi-file $(which keystone-wsgi-admin)

