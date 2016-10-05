#!/usr/bin/env bash

source /bootstrap/functions.sh
get_environment

rabbitmq-server -detached
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rmq-node-1-svc.default.svc
rabbitmqctl start_app
rabbitmqctl cluster_status

