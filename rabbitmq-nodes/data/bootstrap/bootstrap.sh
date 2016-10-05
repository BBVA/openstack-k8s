#!/usr/bin/env bash

source /bootstrap/functions.sh
get_environment

KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)

name_pod_raw=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/pods/ | jq . | grep rmq-node-1- | grep name\" )
name_pod=$(echo $name_pod_raw | awk -F"\"" '{print $4}' )
ip_raw=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/pods/$name_pod/ | jq . | grep podIP)
ip_pod=$(echo $ip_raw | awk -F"\"" '{print $4}' )

echo "$ip_pod $name_pod" >> /etc/hosts 

echo $RABBIT_COOKIE > /var/lib/rabbitmq/.erlang.cookie 
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie 
chmod 400 /var/lib/rabbitmq/.erlang.cookie 

rabbitmq-server -detached 
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@$name_pod
rabbitmqctl start_app

rabbitmqctl stop
sleep 4
rabbitmq-server 






curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/pods/ | jq -c '.items[] | select(.status.containerStatuses[].name | contains("rmq"))' | jq '. | { name: .metadata.name, IP: .status.podIP}'