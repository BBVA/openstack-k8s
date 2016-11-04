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
SQL_SCRIPT=/bootstrap/cinder.sql

############################
# CONFIGURE GLANCE
############################
re_write_file "/controller/cinder/cinder.conf" "/etc/cinder/"
fix_configs $SQL_SCRIPT

MI_IP=`ip a | grep 10.4 | awk '{print $2}' | cut -d"/" -f1`
echo "El valor de MY_IP es: $MI_IP"
sed -i "s!^my_ip.*=.*!my_ip = $MI_IP!" /etc/cinder/cinder.conf

cat >/etc/cinder/nfs_shares <<EOF
172.16.26.11:/vol_NFS_CLOUD_EP_cinder1
172.16.26.12:/vol_NFS_CLOUD_EP_cinder2
EOF

cat >/usr/local/lib/python2.7/dist-packages/cinder/db/sqlalchemy/migrate_repo/migrate.cfg <<EOF
[db_settings]
repository_id=cinder
version_table=migrate_version
required_dbs=[]
EOF

############################
# DATABASE BOOTSTRAP
############################


if ! does_db_exist cinder; then

    # create database
    mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT

    # configure the service and endpoint url
    export OS_USERNAME=$ADMIN_USER_NAME
    export OS_PASSWORD=$ADMIN_PASSWORD
    export OS_TENANT_NAME=$ADMIN_TENANT_NAME
    export OS_AUTH_URL=$OS_URL

    openstack service create  --name cinder --description "OpenStack Block Storage" volume
    openstack service create  --name cinderv2 --description "OpenStack Block Storage" volumev2
    openstack endpoint create --region $REGION volume public https://$CINDER_OFUSCADO/v1/%\(tenant_id\)s
    openstack endpoint create --region $REGION volume internal http://$CINDER_HOSTNAME:8776/v1/%\(tenant_id\)s
    openstack endpoint create --region $REGION volume admin http://$CINDER_HOSTNAME:8776/v1/%\(tenant_id\)s
    openstack endpoint create --region $REGION volumev2 public https://$CINDER_OFUSCADO/v2/%\(tenant_id\)s
    openstack endpoint create --region $REGION volumev2 internal http://$CINDER_HOSTNAME:8776/v2/%\(tenant_id\)s
    openstack endpoint create --region $REGION volumev2 admin http://$CINDER_HOSTNAME:8776/v2/%\(tenant_id\)s
    openstack user create --domain default --password $CINDER_PASSWORD $CINDER_USERNAME
    openstack role add --project services --user $CINDER_USERNAME admin

     # sync the database
    cinder-manage db sync

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


# start cinder service
cinder-scheduler --config-file=/etc/cinder/cinder.conf &
cinder-api --config-file=/etc/cinder/cinder.conf &
cinder-volume --config-file=/etc/cinder/cinder.conf

sleep 1d
