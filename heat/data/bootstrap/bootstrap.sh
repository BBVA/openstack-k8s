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
SQL_SCRIPT=/bootstrap/heat.sql

############################
# CONFIGURE HEAT
############################
# llamada a la funcion del configuration.sh
re_write_file "/controller/heat/heat.conf" "/etc/heat/"
fix_configs $SQL_SCRIPT

cat >/usr/local/lib/python2.7/dist-packages/heat/db/sqlalchemy/migrate_repo/migrate.cfg <<EOF
[db_settings]
repository_id=heat
version_table=migrate_version
required_dbs=[]
EOF

############################
# DATABASE BOOTSTRAP
############################


if ! does_db_exist heat; then

    # create database
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT

    # configure the service and endpoint url
    export OS_USERNAME=$ADMIN_USER_NAME
    export OS_PASSWORD=$ADMIN_PASSWORD
    export OS_TENANT_NAME=$ADMIN_TENANT_NAME
    export OS_AUTH_URL=$OS_URL

    openstack service create  --name heat --description "Orchestration" orchestration
    openstack service create  --name heat-cfn --description "Orchestration" cloudformation
    openstack endpoint create --region $REGION orchestration public https://$HEAT_OFUSCADO/v1/%\(tenant_id\)s
    openstack endpoint create --region $REGION orchestration internal http://$HEAT_HOSTNAME:8004/v1/%\(tenant_id\)s
    openstack endpoint create --region $REGION orchestration admin http://$HEAT_HOSTNAME:8004/v1/%\(tenant_id\)s
    openstack endpoint create --region $REGION cloudformation public https://$HEAT_OFUSCADO/v1
    openstack endpoint create --region $REGION cloudformation internal http://$HEAT_HOSTNAME:8000/v1
    openstack endpoint create --region $REGION cloudformation admin http://$HEAT_HOSTNAME:8000/v1
    openstack user create --domain default --password $HEAT_PASSWORD $HEAT_USERNAME
    openstack role add --project services --user $HEAT_USERNAME admin
    openstack domain create --description "Stack projects and users" heat
    openstack user create --domain heat --password $HEAT_PASSWORD heat_domain_admin
    openstack role add --domain heat --user-domain heat --user heat_domain_admin admin
    openstack role create heat_stack_owner
    openstack role create heat_stack_user

    # sync the database
    heat-manage db_sync

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


# start heat service
heat-api --config-file /etc/heat/heat.conf &
heat-api-cfn --config-file /etc/heat/heat.conf &
heat-engine --config-file /etc/heat/heat.conf