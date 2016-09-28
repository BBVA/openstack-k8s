#!/usr/bin/env bash

function get_environment () {


        RAIZ="http://etcd:2379/v2/keys/general"

        # solo hay que cambiar los valores del array environment

        RESULT_PARAMS=`curl -fs -X GET $RAIZ`
		NPARAMS=`echo $RESULT_PARAMS | jq .node.nodes | jq '. | length'`
		CPARAMS=0

		while [ $CPARAMS -lt $NPARAMS ]; do

			value=$(echo $RESULT_PARAMS | jq .node.nodes[$CPARAMS].value | sed 's/"//g')
			key_path=$(echo $RESULT_PARAMS | jq .node.nodes[$CPARAMS].key | sed 's/"//g')
			key=`echo $key_path | awk -F"/" '{print $3}'`

			export $key=$value
			let CPARAMS=CPARAMS+1
		done


}

