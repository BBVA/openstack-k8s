

source functions.sh
get_environment

rabbitmq-server -detached
sleep 2

rabbitmqctl add_user $RABBIT_USERID $RABBIT_PASSWORD
rabbitmqctl set_user_tags $RABBIT_USERID administrator 
rabbitmqctl set_permissions -p / $RABBIT_USERID  ".*" ".*" ".*" 

rabbitmqctl delete_user guest
rabbitmqctl stop
echo "*** User '$RABBITMQ_USER' with password '$RABBITMQ_PASSWORD' completed. ***"
echo "*** Log in the WebUI at port 15672 ***"

sleep 2
ulimit -S -n 65536
rabbitmq-server &