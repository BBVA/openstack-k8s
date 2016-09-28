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

apache2ctl -DFOREGROUND


