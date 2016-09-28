#!/usr/bin/env bash

#############################
# Include scripts
#############################
source /bootstrap/configuration-swift.sh
source /bootstrap/configuration.sh
source /bootstrap/environment.sh

#############################
# variables and environment
#############################
get_environment

############################
# CONFIGURE SWIFT
############################

re_write_file_swift "/controller/swift/proxy-server.conf" "/etc/swift/"
re_write_file "controller/swift/rsyncd.conf" "/etc/"
re_write_file "controller/swift/rsync" "/etc/default/"
re_write_file_swift "controller/swift/account-server.conf" "/etc/swift/"
re_write_file_swift "controller/swift/container-server.conf" "/etc/swift/"
re_write_file_swift "controller/swift/object-server.conf" "/etc/swift/"
re_write_file_swift "controller/swift/swift.conf" "/etc/swift/"

cp /bootstrap/*.gz /etc/swift/

MI_IP=`ip a | grep 10.4 | awk '{print $2}' | cut -d"/" -f1`
echo "El valor de MY_IP es: $MI_IP"
sed -i "1i address = $MI_IP" /etc/rsyncd.conf
sed -i "s%^.*bind_ip.*=.*%bind_ip = $MI_IP%" /etc/swift/account-server.conf
sed -i "s%^.*bind_ip.*=.*%bind_ip = $MI_IP%" /etc/swift/container-server.conf
sed -i "s%^.*bind_ip.*=.*%bind_ip = $MI_IP%" /etc/swift/object-server.conf

chown -R root:swift /etc/swift

############################
# DATABASE BOOTSTRAP
############################

swift_is_installed=`openstack service list | grep swift |wc -l`

if [ $swift_is_installed == "0" ]; then

    # configure the service and endpoint url
    export OS_USERNAME=$ADMIN_USER_NAME
    export OS_PASSWORD=$ADMIN_PASSWORD
    export OS_TENANT_NAME=$ADMIN_TENANT_NAME
    export OS_AUTH_URL=$OS_URL

    openstack user create --domain default --project services --password $SWIFT_PASSWORD $SWIFT_USERNAME
    openstack role add --project services --user $SWIFT_USERNAME admin
    openstack service create  --name swift --description "Openstack Object Storage" object-store
    openstack endpoint create --region $REGION object-store public https://$SWIFT_OFUSCADO/v1/AUTH_%\(tenant_id\)s
    openstack endpoint create --region $REGION object-store internal http://$SWIFT_HOSTNAME:8080/v1/AUTH_%\(tenant_id\)s
    openstack endpoint create --region $REGION object-store admin http://$SWIFT_HOSTNAME:8080/v1

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

# start extra services
rsync --daemon &
# start swift service
swift-proxy-server /etc/swift/proxy-server.conf &
# start rings services
#swift-init all start 
swift-container-updater /etc/swift/container-server.conf &
swift-account-auditor /etc/swift/account-server.conf &
swift-object-replicator /etc/swift/object-server.conf &
swift-container-replicator /etc/swift/container-server.conf &
swift-object-auditor /etc/swift/object-server.conf &
swift-container-auditor /etc/swift/container-server.conf &
swift-container-server /etc/swift/container-server.conf &
swift-object-reconstructor /etc/swift/object-server.conf &
swift-object-server /etc/swift/object-server.conf &
swift-account-reaper /etc/swift/account-server.conf &
swift-account-replicator /etc/swift/account-server.conf &
swift-object-updater /etc/swift/object-server.conf &
swift-account-server /etc/swift/account-server.conf


