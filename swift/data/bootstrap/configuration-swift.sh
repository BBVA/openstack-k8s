#!/usr/bin/env bash

function re_write_file_swift (){

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

                       # echo $key=$value

                        sed -i -e "
                                /^.*\[$section\]/,/^\[/ {
                                      s&^.*$key.*=.*$&$key=$value&
                        }
                        " $PATH_DIRECTORY$file_conf


                        sed -i -e "s/^.*$section.*$/\[$section\]/" $PATH_DIRECTORY$file_conf

                        let CPARAMS=CPARAMS+1
                done
                let CSECTION=CSECTION+1

        done

}

