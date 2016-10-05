#!/usr/bin/env bash

source /bootstrap/functions.sh
get_environment

rabbitmq-server -detached -setcookie $RABBIT_COOKIE
sleep 6

rabbitmqctl add_user $RABBIT_USERID $RABBIT_PASSWORD
rabbitmqctl set_user_tags $RABBIT_USERID administrator 
rabbitmqctl set_permissions -p / $RABBIT_USERID  ".*" ".*" ".*" 

rabbitmqctl delete_user guest
rabbitmqctl stop
sleep 4

echo "*** User creation completed. ***"
echo "*** Log in the WebUI at port 15672 ***"

ulimit -S -n 65536
rabbitmq-server -setcookie $RABBIT_COOKIE

