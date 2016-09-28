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
SQL_SCRIPT=/bootstrap/nova.sql

############################
# CONFIGURE NOVA
############################
# llamada a la funcion del configuration.sh
re_write_file "/controller/nova/nova.conf" "/etc/nova/"
fix_configs $SQL_SCRIPT
sleep 5
MI_IP=`ip a | grep 10.4 | awk '{print $2}' | cut -d"/" -f1`
echo "El valor de MY_IP es: $MI_IP"
sed -i "s!^my_ip.*=.*!my_ip = $MI_IP!" /etc/nova/nova.conf
sed -i "s!^#metadata_host.*=.*!metadata_host = $MI_IP!" /etc/nova/nova.conf

############################
# DATABASE BOOTSTRAP
############################

if ! does_db_exist nova; then

    # create database
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT

cat >/usr/local/lib/python2.7/dist-packages/nova/db/sqlalchemy/migrate_repo/migrate.cfg <<EOF
[db_settings]
repository_id=nova
version_table=migrate_version
required_dbs=[]
EOF

cat >/usr/local/lib/python2.7/dist-packages/nova/db/sqlalchemy/api_migrations/migrate_repo/migrate.cfg <<EOF
[db_settings]
repository_id=nova_api
version_table=migrate_version
required_dbs=[]
EOF


    # sync the database
    nova-manage db sync
    nova-manage api_db sync

    # configure the service and endpoint url
    export OS_USERNAME=$ADMIN_USER_NAME
    export OS_PASSWORD=$ADMIN_PASSWORD
    export OS_TENANT_NAME=$ADMIN_TENANT_NAME
    export OS_AUTH_URL=$OS_URL

    openstack service create  --name nova --description "Openstack Compute" compute
    openstack user create --domain default --password $NOVA_PASSWORD $NOVA_USERNAME
    openstack role add --project services --user $NOVA_USERNAME admin
    openstack endpoint create --region $REGION compute public https://$NOVA_OFUSCADO/v2.1/%\(tenant_id\)s
    openstack endpoint create --region $REGION compute internal http://$NOVA_HOSTNAME:8774/v2.1/%\(tenant_id\)s
    openstack endpoint create --region $REGION compute admin http://$NOVA_HOSTNAME:8774/v2.1/%\(tenant_id\)s

    #openstack service create  --name ec2 --description "Openstack Compute EC2" ec2
    #openstack endpoint create --region $REGION ec2 public https://$NOVA_EC2_OFUSCADO/services/Cloud
    #openstack endpoint create --region $REGION ec2 internal http://$NOVA_HOSTNAME:8773/services/Cloud
    #openstack endpoint create --region $REGION ec2 admin http://$NOVA_HOSTNAME:8773/services/Cloud

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


#patch necesario por el bug de paramiko#######
cd /usr/local/lib/python2.7/dist-packages/nova
cp crypto.py crypto.py.bak
patch -p1 < /bootstrap/patch_Paramiko
cd -
##############################################

nova-api &
nova-cert &
nova-consoleauth &
nova-scheduler &
nova-conductor
