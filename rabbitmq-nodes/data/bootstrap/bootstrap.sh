#!/usr/bin/env bash

source /bootstrap/functions.sh
get_environment

echo $RABBIT_COOKIE > /var/lib/rabbitmq/.erlang.cookie 
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie 
chmod 400 /var/lib/rabbitmq/.erlang.cookie 

rabbitmq-server -detached 
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rmq-node-1-svc.default.svc
rabbitmqctl start_app

rabbitmqctl stop
sleep 2
rabbitmq-server 

