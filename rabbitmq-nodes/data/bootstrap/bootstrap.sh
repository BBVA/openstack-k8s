

source functions.sh
get_environment

rabbitmq-server -detached
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rabbitmq-server.default.svc
rabbitmqctl start_app
rabbitmqctl cluster_status

