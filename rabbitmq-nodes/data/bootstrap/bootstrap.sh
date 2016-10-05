#!/usr/bin/env bash

source /bootstrap/functions.sh
get_environment

rabbitmq-server -detached -setcookie $RABBIT_COOKIE
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rmq-node-1-svc.default.svc
rabbitmqctl start_app

rabbitmqctl stop
sleep 2
rabbitmq-server -setcookie $RABBIT_COOKIE

