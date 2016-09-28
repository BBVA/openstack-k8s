#!/usr/bin/env bash

function fix_configs () {
        if [ $# -eq 0 ]
        then
                echo -e "\n\n *** ERROR ***: No arguments given. Please specify the configuration file or directory contining the configuration files that need to be changed"
                exit
        fi
	for conffile in `find $@ -type f`
	do
	    cat $conffile | envsubst | sponge $conffile
	done

}

function re_write_file (){

        if [ -z "$1" ]
        then
                echo -e "\n\n *** ERROR ***: Arguments 1 are empty. Please write the key like /role/service/file. Example: /controller/keystone/keystone.conf"
                exit
        fi

        if [ -z "$2" ]
        then
                echo -e "*\n\n *** ERROR ***: Argument 2 are empty. Please write the path directory of the file. Example: /etc/keystone/"
                exit
        else
                PATH_DIRECTORY=$2
        fi


        RAIZ="http://etcd:2379/v2/keys$1/"

        RESULT=`curl -fs -X GET $RAIZ`
        NSECTION=`echo $RESULT | jq .node.nodes | jq '. | length'`
        CSECTION=0
        file_conf=`echo $1 | awk -F"/" '{print $4}'`

        while [ $CSECTION -lt $NSECTION ]; do
                section_path=$(echo $RESULT | jq .node.nodes[$CSECTION].key | sed 's/"//g')
                key_params=`echo $section_path | awk -F"/" '{print $5}'`
                section=`echo $section_path| awk -F"/" '{print $5}'`

                RESULT_PARAMS=`curl -fs -X GET $RAIZ$key_params`
                NPARAMS=`echo $RESULT_PARAMS | jq .node.nodes | jq '. | length'`
                CPARAMS=0

                echo "[$section]"

                while [ $CPARAMS -lt $NPARAMS ]; do

                        value=$(echo $RESULT_PARAMS | jq .node.nodes[$CPARAMS].value | sed 's/"//g')
                        key_path=$(echo $RESULT_PARAMS | jq .node.nodes[$CPARAMS].key | sed 's/"//g')
                        key=`echo $key_path | awk -F"/" '{print $6}'`

                        echo $key=$value

                        let CPARAMS=CPARAMS+1
                done
                let CSECTION=CSECTION+1

        done  | crudini --merge $PATH_DIRECTORY$file_conf
        fix_configs $2
}

function does_db_exist {
  local db="${1}"

  local output=$(mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -s -N -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '${db}'" information_schema)
  if [[ -z "${output}" ]]; then
    return 1 # does not exist
  else
    return 0 # exists
  fi
}

